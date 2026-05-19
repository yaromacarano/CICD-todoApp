# Troubleshooting

## Purpose

This document contains checks for common issues in the local build, Docker image build, GitLab CI pipeline, SonarQube analysis, AWS ECR push, and AWS ECS deployment.

## GitLab job is stuck or not picked by runner

The pipeline uses a self-hosted GitLab Runner hosted on AWS EC2.

Check that the runner is online and has the required tags:

- `aws`
- `docker`
- `ec2`

Also check:

- the runner is registered to the correct GitLab project;
- the runner is active and not paused;
- the `.gitlab-ci.yml` default tags match the runner tags;
- the runner can execute Docker commands;
- the runner has network access to AWS services;
- the runner has network access to the SonarQube server.

## Maven build fails

### Check Java version

Command:

- `java -version`

The project uses Java 17.

### Check Maven version

Command:

- `mvn -version`

Maven 3.9+ is used for the project build.

### Run clean verification

Command:

- `mvn clean verify`

This helps confirm whether the issue is related to compilation, tests, or project configuration.

## Local run fails because data directory is missing

The application expects a `data/` directory in the project root during local execution.

Check that the repository contains:

- `data/.gitkeep`

If the directory is missing, create it manually:

- `mkdir -p data`

Docker and ECS runs are not affected by this local issue because the Docker image creates the required directory during image build.

## JAR file is missing

The Docker build uses the application JAR from the `target/` directory.

Build the artifact first:

- `mvn clean package`

Application artifact:

- `target/todolist-app-1.0.0.jar`

## Docker image build fails

### Check Docker

Command:

- `docker version`

### Check artifact path

Confirm that the JAR referenced by the `Dockerfile` exists in `target/`.

### Build image manually

Command:

- `docker build -t todo-app:gitlab-ci .`

## Container starts but application is not available

### Check container status

Command:

- `docker ps`

### Check logs

Command:

- `docker logs <container_id>`

### Check port mapping

The application runs on port `8080`:

- `docker run --rm -p 8080:8080 todo-app:gitlab-ci`

## GitLab pipeline does not start

Check `.gitlab-ci.yml` rules.

Current validation jobs run for:

- `main`;
- `develop`;
- merge request pipelines;
- scheduled pipelines;
- manual web pipelines.

Current push and deploy jobs run only for:

- `main`.

If the pipeline is expected to run from another branch, update the job rules or run the project from the branch configured in the rules.

## GitLab pipeline cannot access variables

Check GitLab CI/CD variables:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_DEFAULT_REGION`
- `ECR_REGISTRY`
- `ECR_REPOSITORY`
- `ECS_CLUSTER`
- `ECS_SERVICE`
- `ECS_TASK_FAMILY`
- `SONAR_HOST_URL`
- `SONAR_TOKEN`

Also check whether variables are protected. Protected variables are available only for protected branches and tags.

## SonarQube analysis fails

Check GitLab CI/CD SonarQube variables:

- `SONAR_HOST_URL`
- `SONAR_TOKEN`

Also check:

- SonarQube server is running;
- GitLab Runner can reach the SonarQube URL;
- SonarQube token is valid;
- project key and scanner configuration are correct;
- `target/classes/` exists from the build job;
- `target/checkstyle-result.xml` exists.

## Quality Gate stage fails or times out

The SonarQube scanner waits for the Quality Gate result.

Check:

- SonarQube server is reachable from GitLab Runner;
- SonarQube analysis completed successfully;
- Quality Gate exists in SonarQube;
- project key is correct;
- `SONAR_TOKEN` has enough permissions.

## ECR push fails

Check AWS variables in GitLab CI/CD settings.

Check AWS CLI access from a local machine or runner:

- `aws sts get-caller-identity`

Check ECR repository access:

- `aws ecr describe-repositories --region us-east-1`

Common causes:

- invalid AWS credentials;
- missing ECR permissions;
- wrong AWS region;
- ECR repository does not exist;
- Docker-in-Docker service is not available;
- Docker is not authenticated to ECR.

## Docker-in-Docker fails

The `push-image-job` uses:

- `docker:27.1.1-dind`

Check:

- `DOCKER_HOST` is set to `tcp://docker:2375`;
- `DOCKER_TLS_CERTDIR` is empty;
- GitLab Runner allows Docker-in-Docker;
- the runner has enough disk space.

## ECS task definition registration fails

Check:

- `aws/task-definition-template.json` exists;
- `IMAGE_URI_PLACEHOLDER` exists in the template;
- generated file `aws/task-definition.json` is valid JSON;
- ECS execution role ARN is correct;
- GitLab AWS credentials have `ecs:RegisterTaskDefinition`;
- GitLab AWS credentials have `iam:PassRole`;
- image URI points to an existing ECR image tag.

## ECS deployment fails

Check:

- ECS cluster exists;
- ECS service exists;
- `ECS_CLUSTER` variable is correct;
- `ECS_SERVICE` variable is correct;
- `ECS_TASK_FAMILY` variable is correct;
- GitLab AWS credentials have `ecs:UpdateService`;
- AWS region is correct;
- ECS service has valid networking configuration.

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
