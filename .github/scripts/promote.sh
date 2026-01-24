#!/bin/bash
set -euo pipefail

#################################################
# Config
#################################################

STAGING_VALS="helm/hello-app-k8s/values-staging.yaml"
PROD_VALS="helm/hello-app-k8s/values-prod.yaml"

BOT_NAME="github-actions[bot]"
BOT_EMAIL="github-actions[bot]@users.noreply.github.com"

#################################################
# Git Identity
#################################################

git config user.name "$BOT_NAME"
git config user.email "$BOT_EMAIL"

#################################################
# Fetch Latest
#################################################

echo "🔄 Fetching latest branches..."
git fetch origin

#################################################
# Prepare main branch
#################################################

echo "📥 Syncing main branch..."
git checkout main
git pull origin main

#################################################
# Read From Staging Values
#################################################

echo "📖 Reading staging values..."

if [ ! -f "$STAGING_VALS" ]; then
  echo "❌ ERROR: $STAGING_VALS not found"
  exit 1
fi

TAG=$(yq e '.image.tag' "$STAGING_VALS")
DIGEST=$(yq e '.image.digest' "$STAGING_VALS")

if [[ -z "$TAG" || "$TAG" == "null" ]]; then
  echo "❌ ERROR: image.tag missing in staging values"
  exit 1
fi

if [[ -z "$DIGEST" || "$DIGEST" == "null" ]]; then
  echo "❌ ERROR: image.digest missing in staging values"
  exit 1
fi

echo "✅ Found TAG=$TAG"
echo "✅ Found DIGEST=$DIGEST"

#################################################
# Validate Commit ↔ Image Tag Match
#################################################

echo "🔍 Validating staging commit matches image tag..."

STAGING_SHA_FULL=$(git rev-parse origin/staging)
STAGING_SHA_SHORT="${STAGING_SHA_FULL:0:7}"

EXPECTED_TAG="sha-${STAGING_SHA_SHORT}"

echo "🧾 Staging commit:  $STAGING_SHA_SHORT"
echo "🏷️  Image tag:      $TAG"
echo "🎯 Expected tag:   $EXPECTED_TAG"

if [[ "$TAG" != "$EXPECTED_TAG" ]]; then
  echo "❌ ERROR: Image tag does not match staging commit!"
  echo "   Expected: $EXPECTED_TAG"
  echo "   Found:    $TAG"
  echo "   Aborting promotion."
  exit 1
fi

echo "✅ Commit and image tag match"

#################################################
# Create Release Branch
#################################################

RELEASE_BRANCH="release/${TAG}"

echo "🌿 Creating release branch: $RELEASE_BRANCH"

if git show-ref --quiet "refs/heads/$RELEASE_BRANCH"; then
  echo "❌ ERROR: Branch $RELEASE_BRANCH already exists"
  exit 1
fi

git checkout -b "$RELEASE_BRANCH"

#################################################
# Merge Staging
#################################################

echo "🔀 Merging staging into $RELEASE_BRANCH..."

if ! git merge origin/staging \
  -m "chore(release): merge staging for $TAG" \
  -X theirs; then

  echo "❌ ERROR: Merge failed"
  exit 1
fi

#################################################
# Save Previous Production Version (Rollback)
#################################################

echo "💾 Saving previous production version..."

OLD_TAG=$(yq e '.image.tag' "$PROD_VALS")
OLD_DIGEST=$(yq e '.image.digest' "$PROD_VALS")

if [[ "$OLD_TAG" != "null" && -n "$OLD_TAG" ]]; then
  yq -i ".image.previous.tag = \"$OLD_TAG\"" "$PROD_VALS"
fi

if [[ "$OLD_DIGEST" != "null" && -n "$OLD_DIGEST" ]]; then
  yq -i ".image.previous.digest = \"$OLD_DIGEST\"" "$PROD_VALS"
fi

#################################################
# Update Production Values
#################################################

echo "✏️ Updating production values..."

yq -i ".image.tag = \"$TAG\"" "$PROD_VALS"
yq -i ".image.digest = \"$DIGEST\"" "$PROD_VALS"

#################################################
# Validate Production Values
#################################################

FINAL_TAG=$(yq e '.image.tag' "$PROD_VALS")
FINAL_DIGEST=$(yq e '.image.digest' "$PROD_VALS")

if [[ "$FINAL_TAG" != "$TAG" || "$FINAL_DIGEST" != "$DIGEST" ]]; then
  echo "❌ ERROR: Production values not updated correctly"
  exit 1
fi

echo "✅ Production values updated"

#################################################
# Commit Promotion
#################################################

echo "📦 Committing promotion..."

git add "$PROD_VALS"

git commit -m "chore(release): promote $TAG to production" \
  -m "Image digest: $DIGEST" \
  -m "Previous: ${OLD_TAG:-N/A}"

#################################################
# Push Branch
#################################################

echo "🚀 Pushing $RELEASE_BRANCH..."

git push origin "$RELEASE_BRANCH"

#################################################
# Create Pull Request
#################################################

echo "📬 Creating Pull Request..."

gh pr create \
  --base main \
  --head "$RELEASE_BRANCH" \
  --title "🚀 Release: $TAG → Production" \
  --body "$(cat <<EOF
Automated promotion from staging to production.

### 📦 Image
- Tag: $TAG
- Digest: $DIGEST

### ⏪ Rollback
- Previous tag: ${OLD_TAG:-N/A}

### 🔐 Integrity
- Source commit: $STAGING_SHA_SHORT
- Tag verified: ✅

### 🤖 Automation
- GitHub Run ID: ${GITHUB_RUN_ID}

Please review and approve.
EOF
)"

echo "🎉 Promotion PR created successfully!"
