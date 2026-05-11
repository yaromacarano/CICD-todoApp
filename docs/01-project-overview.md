# Project Overview

## Purpose

This project documents a CI/CD workflow for a Java Spring Boot Todo application.

The application is used as a practical base for DevOps work: build automation, static checks, containerization, image publishing, and deployment to AWS ECS.

## Main workflow

GitHub → Jenkins → Maven → Checkstyle → SonarQube → Docker → AWS ECR → AWS ECS

The workflow covers:

1. Source code checkout from GitHub.
2. Maven verification.
3. Checkstyle analysis.
4. SonarQube analysis.
5. Quality Gate validation.
6. Maven package build.
7. Docker image build.
8. Image push to AWS ECR.
9. ECS task definition revision deployment.

## Main components

- **Spring Boot application:** web application used as the deployment target.
- **Maven:** build, verification, and packaging.
- **Dockerfile:** runtime image definition for the application.
- **Jenkinsfile:** CI/CD pipeline definition.
- **Checkstyle:** Java style and static analysis report.
- **SonarQube:** code quality analysis and Quality Gate.
- **AWS ECR:** Docker image registry.
- **AWS ECS:** runtime environment for the containerized application.

## DevOps scope

The DevOps part of the repository covers:

- GitHub-based source control;
- Jenkins declarative pipeline;
- Maven build lifecycle;
- code quality checks before image publishing;
- Docker image creation;
- image publishing to AWS ECR;
- ECS service deployment trigger;
- technical documentation for setup and troubleshooting.

## Architecture

The project follows a simple CI/CD architecture:

1. Developer pushes code to GitHub.
2. Jenkins checks out the repository.
3. Jenkins builds, verifies, scans, and packages the application.
4. Jenkins builds a Docker image.
5. Jenkins pushes the image to AWS ECR.
6. Jenkins creates a new ECS task definition revision and updates the ECS service to use it.

## Repository files related to DevOps

- `Jenkinsfile` — defines the full CI/CD pipeline.
- `Dockerfile` — defines how the application image is built.
- `pom.xml` — defines Maven build, dependencies, and plugins.
- `docs/` — contains technical documentation for the project.
- `docs/screenshots/v1.1-ecs-task-revision-deployment` — stores visual proof of pipeline and deployment results.
- `aws/task-definition-template.json` — ECS task definition template used for deployment revision creation

## Portfolio value

This repository shows practical experience with tools that are common in Junior DevOps and Cloud job descriptions:

- Linux-based build environment;
- Git and GitHub workflow;
- Jenkins pipeline automation;
- Maven build process;
- Docker image lifecycle;
- SonarQube quality control;
- AWS ECR and ECS deployment flow;
- documentation of setup, assumptions, and troubleshooting.
