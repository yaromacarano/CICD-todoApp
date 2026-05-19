# Docker Guide

## Purpose

This document describes how the application is packaged and run as a Docker container.

Docker is used to create a consistent runtime image for the Spring Boot application. The same image format is used by the GitLab CI pipeline before publishing to AWS ECR.

## Dockerfile role

The repository contains a `Dockerfile` that runs the built Spring Boot JAR with Java 17.

The image build uses the JAR file from the `target/` directory.

The Docker image creates the required `data/` directory during image build. The `data/.gitkeep` file is only used for local execution from the repository root. Docker and ECS use the directory created inside the image.

## Build application artifact

Command:

- `mvn clean package -DskipTests`

Expected artifact:

- `target/todolist-app-1.0.0.jar`

## Build Docker image

Command:

- `docker build -t todo-app:gitlab-ci .`

## Check image

Command:

- `docker images | grep todo-app`

## Run container

Command:

- `docker run --rm -p 8080:8080 todo-app:gitlab-ci`

Application URL:

- `http://localhost:8080`

## Check running container

Command:

- `docker ps`

## Stop container

When the container is running in the foreground, use `Ctrl + C`.

If the container is running in detached mode:

- `docker stop <container_id>`

## Docker image flow in GitLab CI

The GitLab pipeline builds and publishes the image in the `push` stage.

The image is tagged with:

- `CI_PIPELINE_IID`

Image format:

- `$ECR_REGISTRY/$ECR_REPOSITORY:$CI_PIPELINE_IID`

The same image tag is used during the ECS task definition revision deployment.

## Docker-in-Docker

The `push-image-job` uses Docker-in-Docker through the `docker:27.1.1-dind` service.

The job installs:

- `docker-cli`
- `aws-cli`

Then it authenticates to AWS ECR, builds the image, and pushes it to the configured ECR repository.

## Docker checks

A successful Docker setup confirms that:

- the application can be packaged into a runtime image;
- the container exposes the application port;
- the image can be pushed to AWS ECR;
- the image can be used by AWS ECS after deployment.
