# Docker Guide

## Purpose

This document describes how the application is packaged and run as a Docker container.

Docker is used to create a consistent runtime image for the Spring Boot application. The same image format is built by GitHub Actions before publishing to AWS ECR.

## Dockerfile role

The repository contains a `Dockerfile` that runs the built Spring Boot JAR with Java 17.

The image build uses the JAR file from the `target/` directory.

---

The Docker image creates the required data/ directory during image build.

The data/.gitkeep file is only used for local execution from the repository root. Docker and ECS use the directory created inside the image.

## Build application artifact

Command:

- `mvn clean package -DskipTests`

Expected artifact:

- `target/todolist-app-1.0.0.jar`

## Build Docker image

Command:

- `docker build -t todo-app:github-actions .`

## Check image

Command:

- `docker images | grep todo-app`

## Run container

Command:

- `docker run --rm -p 8080:8080 todo-app:github-actions`

Application URL:

- `http://localhost:8080`

## Check running container

Command:

- `docker ps`

## Stop container

When the container is running in the foreground, use `Ctrl + C`.

If the container is running in detached mode:

- `docker stop <container_id>`

## Docker image flow in GitHub Actions

The GitHub Actions workflow builds and publishes the image after the Maven and SonarQube stages pass.

Image flow:

- GitHub Actions logs in to AWS ECR.
- The workflow builds the Docker image from the repository `Dockerfile`.
- The image is tagged with the GitHub Actions run number.
- The image is pushed to AWS ECR.
- The pushed image is used in the ECS task definition deployment.

## Image naming

The workflow builds the image using these values:

- `ECR_REGISTRY` — returned by the AWS ECR login action.
- `ECR_REPOSITORY` — loaded from GitHub Actions Variable `ECR_REPOSITORY`.
- `IMAGE_TAG` — GitHub Actions run number from `github.run_number`.

Final image format:

- `ECR_REGISTRY/ECR_REPOSITORY:IMAGE_TAG`

## Docker checks

A successful Docker setup confirms that:

- the application can be packaged into a runtime image;
- the container exposes the application port;
- the image can be pushed to AWS ECR;
- the image can be used by AWS ECS after the task definition is rendered.
