# Docker

## Build and run

```bash
mvn clean package -DskipTests
docker build -t todo-app:gitlab-ci .
docker run --rm -p 8080:8080 todo-app:gitlab-ci
```

Open `http://localhost:8080` and stop the container with `Ctrl+C`.

Useful checks:

```bash
docker images todo-app
docker ps
```

## Pipeline image

The `push-image-job` uses Docker-in-Docker with TLS and tags the image with the pipeline number:

```text
$ECR_REPOSITORY_URL:$CI_PIPELINE_IID
```

Flow:

1. Install AWS CLI in the job container.
2. Authenticate to ECR.
3. Build the image from the application JAR.
4. Push the image to ECR.
5. Deploy the same image URI to ECS.

The Runner configuration enables privileged mode and mounts `/certs/client` for Docker-in-Docker TLS.
