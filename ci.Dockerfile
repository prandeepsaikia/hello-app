# Dockerfile.ci
FROM gcr.io/distroless/java25-debian13:nonroot

WORKDIR /app

COPY build/libs/hello-app.jar app.jar

USER nonroot:nonroot

ENTRYPOINT ["java","-jar","/app/app.jar"]
