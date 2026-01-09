############################
# Stage 1 — Build
############################

FROM openjdk:25-ea-slim AS build-env
LABEL maintainer="Prandeep Saikia"
WORKDIR /app

COPY gradlew .
COPY gradle/ gradle/

COPY build.gradle.kts settings.gradle.kts ./
RUN --mount=type=cache,target=/root/.gradle ./gradlew --no-daemon dependencies


COPY src src
RUN --mount=type=cache,target=/root/.gradle ./gradlew --no-daemon clean build -x check -x test

############################
# Stage 2 — Runtime
############################

FROM gcr.io/distroless/java25-debian13:nonroot
WORKDIR /app

COPY --from=build-env  /app/build/libs/hello-app.jar hello-app.jar

USER nonroot:nonroot
CMD ["hello-app.jar"]
