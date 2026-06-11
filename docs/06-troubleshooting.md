# Troubleshooting

## Purpose

This document contains checks for common issues in the local build, Docker image build, GitHub Actions workflow, SonarQube analysis, AWS ECR push, and AWS ECS deployment.

## Local run fails because data directory is missing

The application expects a data/ directory in the project root during local execution.

Check that the repository contains:

- `data/.gitkeep`

If the directory is missing, create it manually:

- `mkdir -p data`

Docker and ECS runs are not affected by this local issue because the Docker image creates the required directory during image build.

## Maven build fails

### Check Java version

Command:

- `java -version`

The project uses Java 21.

### Check Maven version

Command:

- `mvn -version`

Maven 3.9+ is used for the project build.

### Run clean verification

Command:

- `mvn clean verify`

This helps confirm whether the issue is related to compilation, tests, or project configuration.

## JAR file is missing

The Docker build uses the application JAR from the `target/` directory.

Build the artifact first:

- `mvn clean package`

Application artifact:

- `target/todolist-app-1.0.0.jar`

## Docker image build fails

### Check Docker locally

Command:

- `docker version`

### Check artifact path

Confirm that the JAR referenced by the `Dockerfile` exists in `target/`.

### Build image manually

Command:

- `docker build -t todo-app:github-actions .`

## Container starts but application is not available

### Check container status

Command:

- `docker ps`

### Check logs

Command:

- `docker logs <container_id>`

### Check port mapping

The application runs on port `8080`:

- `docker run --rm -p 8080:8080 todo-app:github-actions`

## GitHub Actions workflow does not start

Check workflow triggers in `.github/workflows/deploy.yml`.

Expected triggers:

- push to `github-actions`;
- pull request to `github-actions`;
- manual run through `workflow_dispatch`.

Also check:

- workflow file exists in `.github/workflows/`;
- workflow file is committed to the branch;
- GitHub Actions are enabled for the repository;
- branch name is correct.

## Manual workflow run button is missing

The manual run button appears when the workflow includes:

- `workflow_dispatch`

Also check that the workflow file exists on the branch selected in the Actions UI.

## Java or Maven step fails in GitHub Actions

Check the setup step:

- Java version: `21`
- distribution: `temurin`

The workflow runs on a clean GitHub-hosted runner, so every required setup step must be included in the workflow.

## SonarQube analysis fails

Check GitHub Actions Secrets:

- `SONAR_TOKEN`
- `SONAR_HOST_URL`

Also check:

- SonarQube server is running;
- `SONAR_HOST_URL` is reachable from the public internet if using GitHub-hosted runners;
- Nginx or reverse proxy forwards requests to SonarQube correctly;
- SonarQube token is valid;
- project key and scanner arguments are correct.

## SonarQube connection timeout

A timeout usually means the GitHub-hosted runner cannot reach the SonarQube server.

Check:

- `SONAR_HOST_URL` uses the public URL;
- the URL includes `http://` or `https://`;
- security group or firewall allows access;
- Nginx proxy is working;
- `/api/server/version` is reachable through the same URL.

If SonarQube is behind Nginx on port `80`, the URL should not include `:9000`.

## Quality Gate fails

Check the SonarQube project result.

Common causes:

- Quality Gate conditions are not met;
- new code coverage is below the required value;
- issues or security hotspots require attention;
- SonarQube analysis configuration is incomplete.

## Artifact upload fails

Check that the build created a JAR file in:

- `target/`

The workflow uploads:

- `target/*.jar`

If no file exists, the Maven build stage must be checked first.

## AWS credentials step fails

Check GitHub Actions Secrets:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

Check GitHub Actions Variable:

- `AWS_REGION`

Common causes:

- missing secret;
- wrong secret value;
- invalid AWS access key;
- AWS region not set;
- IAM user or role disabled.

## ECR push fails

Check GitHub Actions Variable:

- `ECR_REPOSITORY`

Check AWS permissions:

- ECR authentication permission exists;
- ECR repository exists;
- IAM user or role can push images;
- AWS region matches the ECR repository region.

Common causes:

- ECR repository does not exist;
- wrong AWS region;
- missing ECR permissions;
- Docker image tag is invalid.

## ECS task definition render fails

Check:

- `aws/task-definition-template.json` exists;
- the JSON is valid;
- the container name in the template matches GitHub Actions Variable `CONTAINER_NAME`;
- the template includes the container that should receive the new image.

## ECS deployment fails

Check GitHub Actions Variables:

- `CLUSTER`
- `SERVICE`
- `CONTAINER_NAME`

Check AWS permissions:

- `ecs:RegisterTaskDefinition`
- `ecs:UpdateService`
- `ecs:DescribeServices`
- `ecs:DescribeTaskDefinition`
- `iam:PassRole`

Common causes:

- ECS cluster does not exist;
- ECS service name is wrong;
- task definition template is invalid;
- ECS execution role cannot be passed;
- service networking is invalid;
- container port does not match the load balancer target group.

## ECS task does not stay running

Check ECS task logs and service events.

Common causes:

- application failed to start;
- container port mismatch;
- missing environment variables;
- task has insufficient CPU or memory;
- security group or load balancer configuration issue;
- task definition image points to the wrong tag or repository.

## Screenshot safety check

Before committing screenshots to GitHub, hide:

- AWS access keys;
- secret keys;
- passwords;
- tokens;
- private URLs if needed;
- sensitive infrastructure details;
- personal data.
