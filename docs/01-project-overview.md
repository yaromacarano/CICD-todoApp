# Project Overview

## Purpose

This project documents a GitHub Actions CI/CD workflow for a Java Spring Boot Todo application.

The application is used as a practical base for DevOps work: build automation, code quality checks, containerization, image publishing, and deployment to AWS ECS.

## Main workflow

GitHub → GitHub Actions → Maven → Checkstyle → SonarQube → Docker → AWS ECR → AWS ECS

The workflow covers:

1. Source code checkout from GitHub.
2. Java 21 setup on a GitHub-hosted runner.
3. Maven verification.
4. Checkstyle analysis.
5. Application build.
6. SonarQube analysis with Quality Gate validation.
7. Build artifact upload.
8. Build artifact download in the deployment job.
9. Docker image build.
10. Image push to AWS ECR.
11. ECS task definition rendering with the new image.
12. ECS service deployment.
13. ECS service stability check.

## Main components

- **Spring Boot application:** web application used as the deployment target.
- **Maven:** build, verification, and packaging.
- **Dockerfile:** runtime image definition for the application.
- **GitHub Actions workflow:** CI/CD automation defined in `.github/workflows/deploy.yml`.
- **Checkstyle:** Java style and static analysis report.
- **SonarQube:** code quality analysis and Quality Gate.
- **AWS ECR:** Docker image registry.
- **AWS ECS:** runtime environment for the containerized application.
- **ECS task definition template:** deployment template stored in `aws/task-definition-template.json`.

## DevOps scope

The DevOps part of the repository covers:

- GitHub-based source control;
- GitHub Actions workflow automation;
- Maven build lifecycle;
- code quality checks before image publishing;
- Docker image creation;
- image publishing to AWS ECR;
- ECS deployment through a new task definition revision;
- technical documentation for setup and troubleshooting.

## Architecture

The project follows a simple CI/CD architecture:

1. Developer pushes code to the `github-actions` branch.
2. GitHub Actions starts the workflow.
3. The workflow builds, verifies, scans, and packages the application.
4. The workflow builds a Docker image.
5. The image is pushed to AWS ECR with the GitHub run number as the tag.
6. GitHub Actions renders a new ECS task definition using the new image.
7. AWS ECS updates the service to the new task definition revision.
8. The workflow waits until the ECS service becomes stable.

## Repository files related to DevOps

- `.github/workflows/deploy.yml` — defines the GitHub Actions CI/CD workflow.
- `aws/task-definition-template.json` — ECS task definition template used during deployment.
- `Dockerfile` — defines how the application image is built.
- `data/.gitkeep` — keeps the local data directory in Git for application runs outside Docker
- `pom.xml` — defines Maven build, dependencies, and plugins.
- `docs/` — contains technical documentation for the project.
- `docs/screenshots/` — stores visual proof of workflow and deployment results.

## Portfolio value

This branch shows practical experience with tools that are common in Junior DevOps and Cloud job descriptions:

- Git and GitHub workflow;
- GitHub Actions CI/CD automation;
- Maven build process;
- Docker image lifecycle;
- SonarQube quality control;
- AWS ECR and ECS deployment flow;
- GitHub Secrets and Variables;
- deployment through ECS task definition revisions;
- documentation of setup, assumptions, and troubleshooting.
