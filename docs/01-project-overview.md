# Project Overview

## Purpose

This project documents a GitLab CI/CD workflow for a Java Spring Boot Todo application.

The application is used as a practical base for DevOps work: build automation, static checks, containerization, image publishing, and deployment to AWS ECS.

## Main workflow

GitLab → GitLab CI → Maven → Checkstyle → SonarQube → Docker → AWS ECR → AWS ECS

The workflow covers:

1. Source code checkout by GitLab Runner.
2. Maven test execution.
3. Checkstyle analysis.
4. Maven package build.
5. SonarQube analysis.
6. Quality Gate validation.
7. Docker image build.
8. Image push to AWS ECR.
9. ECS task definition revision creation.
10. ECS service update.

## Main components

- **Spring Boot application:** web application used as the deployment target.
- **Maven:** build, verification, and packaging.
- **Dockerfile:** runtime image definition for the application.
- **GitLab CI:** CI/CD pipeline defined in `.gitlab-ci.yml`.
- **Checkstyle:** Java style and static analysis report.
- **SonarQube:** code quality analysis and Quality Gate.
- **AWS ECR:** Docker image registry.
- **AWS ECS:** runtime environment for the containerized application.
- **ECS task definition template:** JSON template used to register new ECS revisions.
- **Deployment script:** shell script used by the deploy job.

## DevOps scope

The DevOps part of the repository covers:

- Git-based source control;
- GitLab CI/CD pipeline configuration;
- Maven build lifecycle;
- code quality checks before image publishing;
- Docker image creation;
- image publishing to AWS ECR;
- ECS task definition revision deployment;
- technical documentation for setup and troubleshooting.

## Architecture

The project follows a simple CI/CD architecture:

1. Developer pushes code to the GitLab project.
2. GitLab Runner executes the pipeline.
3. Maven tests, Checkstyle, and package build run in containerized jobs.
4. SonarQube analysis checks code quality.
5. Docker-in-Docker builds and pushes the image to AWS ECR.
6. The deploy job creates a new ECS task definition revision.
7. ECS service is updated to use the latest task definition revision.

## Repository files related to DevOps

- `.gitlab-ci.yml` — defines the GitLab CI/CD pipeline.
- `Dockerfile` — defines how the application image is built.
- `aws/task-definition-template.json` — ECS task definition template used during deployment.
- `scripts/deploy-ecs.sh` — deployment script used by the GitLab deploy job.
- `data/.gitkeep` — keeps the local data directory in Git for application runs outside Docker.
- `pom.xml` — defines Maven build, dependencies, and plugins.
- `docs/` — contains technical documentation for the project.
- `docs/screenshots/` — stores visual proof of pipeline and deployment results.

## Portfolio value

This branch shows practical experience with tools that are common in Junior DevOps and Cloud job descriptions:

- Linux-based CI runners;
- GitLab CI/CD pipeline automation;
- Maven build process;
- Docker image lifecycle;
- Docker-in-Docker usage in CI;
- SonarQube quality control;
- AWS ECR and ECS deployment flow;
- task definition revision deployment;
- secure usage of CI/CD variables;
- documentation of setup, assumptions, and troubleshooting.
