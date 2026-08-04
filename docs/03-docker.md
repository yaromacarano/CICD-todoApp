# Running the Application with Docker

The repository packages the Spring Boot application into the same container format that Jenkins publishes to AWS ECR and deploys through ECS Fargate.

## How the image is built

The `Dockerfile` uses Java 21 and copies the packaged application from `target/`. It also creates `/app/data`, where the application stores its SQLite database inside the container.

The root `.dockerignore` keeps the build context small and prevents local infrastructure files, SSH keys, Git metadata, and other unrelated files from being sent to the Docker daemon.

## Build the application

Create the JAR from the repository root:

```bash
mvn clean package -DskipTests
```

The Docker build expects this exact file:

```text
target/todolist-app-1.0.0.jar
```

## Build the image

```bash
docker build -t todo-app:v1.0 .
```

Confirm that the image exists:

```bash
docker images todo-app
```

## Run the container

```bash
docker run --rm -p 8080:8080 todo-app:v1.0
```

Open:

```text
http://localhost:8080
```

Because the command uses `--rm` and does not mount a volume, the container's SQLite data is removed when the container stops.

## Run in the background

```bash
docker run -d --name todo-app -p 8080:8080 todo-app:v1.0
```

Inspect the running container and its logs:

```bash
docker ps
docker logs -f todo-app
```

Stop and remove it when finished:

```bash
docker stop todo-app
docker rm todo-app
```

## Jenkins image flow

The Jenkins Pipeline handles the image in two stages:

- **Build App Image** builds the image from the repository `Dockerfile`.
- **Upload App Image** authenticates to AWS ECR and pushes the image.

`Jenkinsfile` uses the ECR repository name `todo-app` and tags each image with the Jenkins `BUILD_NUMBER`. The unique tag connects every ECS task definition revision to the Pipeline run that produced it.

## Expected result

The Docker workflow is working when:

- the JAR is packaged into the image;
- the container starts and exposes port `8080`;
- the application responds through the mapped local port;
- Jenkins can use the same image structure for ECR and ECS.
