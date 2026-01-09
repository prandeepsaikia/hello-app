#!/bin/bash
set -e

git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

NEW_RELEASE_BRANCH="release/from-staging-${GITHUB_RUN_ID}"

echo "Starting promotion to $NEW_RELEASE_BRANCH..."

git checkout main
git pull origin main
git checkout -b "$NEW_RELEASE_BRANCH"

git merge origin/staging -m "Merge staging into $NEW_RELEASE_BRANCH" -X theirs

STAGING_VALS="helm/hello-app-k8s/values-staging.yaml"
PROD_VALS="helm/hello-app-k8s/values-prod.yaml"

echo "Reading from $STAGING_VALS"

if [ ! -f "$STAGING_VALS" ]; then
  echo "Error: $STAGING_VALS does not exist"
  exit 1
fi

cat "$STAGING_VALS"

TAG=$(yq e '.image.tag' "$STAGING_VALS")
DIGEST=$(yq e '.image.digest' "$STAGING_VALS")

echo "Parsed TAG=$TAG"
echo "Parsed DIGEST=$DIGEST"

if [ -z "$TAG" ] || [ "$TAG" == "null" ]; then
  echo "Error: Could not find image.tag in $STAGING_VALS"
  exit 1
fi

yq -i ".image.tag = \"$TAG\"" "$PROD_VALS"
yq -i ".image.digest = \"$DIGEST\"" "$PROD_VALS"

git add "$PROD_VALS"
git commit -m "chore(release): promote $TAG to production"

git push origin "$NEW_RELEASE_BRANCH"


# 6. Create the PR using GitHub CLI
gh pr create \
  --base main \
  --head "$NEW_RELEASE_BRANCH" \
  --title "🚀 Release: Merge staging to main ($TAG)" \
  --body "Automated promotion of code and image $TAG from staging to production. Build ID: ${GITHUB_RUN_ID}"