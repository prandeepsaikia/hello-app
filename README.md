# 🦅 Hello App

**Hawk — Platform Engg Task**  

A Java “Hello World” service demonstrating modern cloud-native delivery using Docker, Helm and a secure GitHub Actions CI/CD + GitOps workflow.

---

## 🧩 Overview

This repository contains:

- A lightweight Java application using **virtual threads** that continuously prints `Hello World`
- Unit tests using **JUnit 5**
- A **multi-stage Docker image**
- Kubernetes deployment with **Helm charts**
- A complete **GitHub Actions workflow** for CI/CD with scanning and GitOps
- Static analysis using **Checkstyle** and **SpotBugs**

---

## 🚀 Application Description

The Hello App prints `Hello World` in a loop, running until it is interrupted.  
It uses Java 25’s modern features including virtual threads.

Package: `org.hawk.HelloApp`

---

## 🛠 Build & Run

### Requirements

- Java 25
- Docker
- Gradle
- Helm (optional)
- Kubernetes (optional)

### Build

```bash
./gradlew clean build
```

### Run

```bash
java -jar build/libs/hello-app.jar
```

---

## 🐳 Docker

```bash
docker build -t prandeepsaikia/hello-app:local .
docker run --rm prandeepsaikia/hello-app:local
```

---

## ☸️ Helm

```bash
helm upgrade --install hello-app helm/hello-app-k8s -f helm/hello-app-k8s/values-staging.yaml
```

---

## 🔁 CI/CD

Pipeline stages:

1. Build
2. Test
3. Static Analysis
4. Security Scan
5. Image Build & Push
6. Sign Image
7. Validate Manifests & Update Staging
8. Promotion PR
9. Retag latest

---

## 👤 Maintainer

Prandeep Saikia

---

MIT License
