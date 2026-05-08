# Docker Guide

## Purpose

This document describes how the application is packaged and run as a Docker container.

Docker is used to create a consistent runtime image for the Spring Boot application. The same image format is used by the Jenkins pipeline before publishing to AWS ECR.

## Dockerfile role

The repository contains a `Dockerfile` that runs the built Spring Boot JAR with Java 17.

The image build uses the JAR file from the `target/` directory.

## Build application artifact

Command:

- `mvn clean package -DskipTests`

Expected artifact:

- `target/todolist-app-1.0.0.jar`

## Build Docker image

Command:

- `docker build -t todo-app:v1.0 .`

## Check image

Command:

- `docker images | grep todo-app`

## Run container

Command:

- `docker run --rm -p 8080:8080 todo-app:v1.0`

Application URL:

- `http://localhost:8080`

## Check running container

Command:

- `docker ps`

## Stop container

When the container is running in the foreground, use `Ctrl + C`.

If the container is running in detached mode:

- `docker stop <container_id>`

## Docker image flow in Jenkins

The Jenkins pipeline builds and publishes the image in two stages:

- **Build App Image:** builds the Docker image from the repository Dockerfile.
- **Upload App Image:** pushes the image to AWS ECR.

## Image naming

The current image name in `Jenkinsfile` points to AWS ECR:

- `imageName = "551647579168.dkr.ecr.us-east-1.amazonaws.com/todo-appimg"`

The image is tagged and pushed during the pipeline execution.

## Docker checks

A successful Docker setup confirms that:

- the application can be packaged into a runtime image;
- the container exposes the application port;
- the image can be used by AWS ECS after being pushed to ECR.
