# Docker Guide

## Purpose

Docker packages the Spring Boot JAR into the same runtime image format used by GitHub Actions and Amazon ECS.

The image is based on the Java 21 JRE, runs from `/app`, exposes port `8080`, and starts the application with:

```text
java -jar app.jar
```

## Build the application

The Dockerfile expects this file:

```text
target/todolist-app-1.0.0.jar
```

Create it before building the image:

```bash
mvn clean package -DskipTests
```

For a complete local check, omit `-DskipTests`.

## Build the image

```bash
docker build -t todo-app:github-actions .
```

The `.dockerignore` keeps the build context small. Only the Dockerfile and the required JAR are sent to Docker.

## Run the container

```bash
docker run --rm -p 8080:8080 todo-app:github-actions
```

Open `http://localhost:8080`.

Stop the foreground container with `Ctrl+C`.

## Run in the background

```bash
docker run -d --name todo-app -p 8080:8080 todo-app:github-actions
docker ps
docker logs todo-app
```

Stop and remove it when finished:

```bash
docker stop todo-app
docker rm todo-app
```

## Data directory

The Dockerfile creates `/app/data` for the SQLite database. The data remains inside the container and is removed with the container unless a volume is mounted.

The ECS deployment uses the same container behaviour. When ECS replaces the task, the SQLite data in the old task is not preserved.

## Image flow in GitHub Actions

The `deploy` job:

1. downloads the JAR produced by `build-test-scan`;
2. logs Docker in to Amazon ECR;
3. builds the image from the repository Dockerfile;
4. tags it with `github.run_number`;
5. pushes it to the `todo-app` ECR repository;
6. inserts the complete image URI into a new ECS task definition revision.

The final image name has this format:

```text
AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/todo-app:GITHUB_RUN_NUMBER
```

Using the workflow run number makes it possible to match an ECR image with the GitHub Actions run that created it.

## Common checks

If the build fails, confirm that the JAR exists:

```bash
ls -l target/todolist-app-1.0.0.jar
```

If the container starts but the page does not open, check its status and logs:

```bash
docker ps -a
docker logs todo-app
```

Also confirm that host port `8080` is not already used by another application.
