# GitLab CI Pipeline

## Purpose

This document explains the CI/CD pipeline defined in `.gitlab-ci.yml`.

The pipeline automates the flow from tests and code quality checks to Docker image publishing and AWS ECS deployment.

## Pipeline overview

Maven tests → Checkstyle analysis → Maven package → SonarQube analysis → Docker image push to ECR → ECS task definition revision deployment

## Pipeline stages

The pipeline contains these stages:

1. `test`
2. `build`
3. `sonarqube-check`
4. `push`
5. `deploy`

## GitLab CI variables

The pipeline uses GitLab CI/CD variables for AWS, ECR, ECS, and SonarQube configuration.

Required variables:

- `AWS_ACCESS_KEY_ID` — AWS access key used by GitLab CI.
- `AWS_SECRET_ACCESS_KEY` — AWS secret key used by GitLab CI.
- `AWS_DEFAULT_REGION` — AWS region used by AWS CLI.
- `ECR_REGISTRY` — ECR registry URL.
- `ECR_REPOSITORY` — ECR repository name.
- `ECS_CLUSTER` — ECS cluster name.
- `ECS_SERVICE` — ECS service name.
- `ECS_TASK_FAMILY` — ECS task definition family name.
- `SONAR_HOST_URL` — SonarQube server URL.
- `SONAR_TOKEN` — SonarQube token used by the scanner.

Pipeline-defined variables:

- `IMAGE_TAG` — uses `CI_PIPELINE_IID`.
- `IMAGE_URI` — combines ECR registry, repository, and pipeline image tag.

## Pipeline rules

The current pipeline rules separate validation jobs from deployment jobs.

Validation jobs run for:

- `main` branch;
- `develop` branch;
- merge request pipelines;
- scheduled pipelines;
- manual web pipelines.

SonarQube analysis runs for:

- `main` branch;
- `develop` branch;
- merge request pipelines.

Docker image push and ECS deploy run only for:

- `main` branch.

If this branch is used as a standalone GitLab CI portfolio branch, the deployment rule can be changed from `main` to the selected branch name. If the project is imported to GitLab with `main` as the working branch, the current rules can stay as they are.

## Jobs

### test-job

Runs in the `test` stage.

Image:

- `maven:3.9.9-eclipse-temurin-17`

Commands:

- `mvn test`
- `mvn checkstyle:checkstyle`

This job confirms that the application can be tested and checked before build or deployment.

### build-job

Runs in the `build` stage.

Image:

- `maven:3.9.9-eclipse-temurin-17`

Command:

- `mvn clean package -DskipTests`

Artifacts:

- `target/classes/`
- `target/surefire-reports/`
- `target/checkstyle-result.xml`
- `target/todolist-app-1.0.0.jar`

These artifacts are used by later jobs, especially SonarQube analysis and Docker image build.

### sonarqube-check-job

Runs in the `sonarqube-check` stage.

Image:

- `sonarsource/sonar-scanner-cli:latest`

The job sends code quality data to SonarQube and waits for the Quality Gate result.

Scanner configuration includes:

- project key;
- project name;
- project version;
- source path;
- Java binaries path;
- test reports path;
- Checkstyle report path;
- SonarQube server URL;
- SonarQube token.

### push-image-job

Runs in the `push` stage.

Image:

- `alpine:3.20`

Service:

- `docker:27.1.1-dind`

The job installs Docker CLI and AWS CLI, authenticates to AWS ECR, builds the Docker image, and pushes it to the ECR repository.

Image tag:

- `CI_PIPELINE_IID`

### deploy-ecs-job

Runs in the `deploy` stage.

Image:

- `amazon/aws-cli:2.17.44`

The job runs:

- `scripts/deploy-ecs.sh`

Deployment flow:

1. Replace `IMAGE_URI_PLACEHOLDER` in `aws/task-definition-template.json`.
2. Create `aws/task-definition.json`.
3. Register a new ECS task definition revision.
4. Update ECS service to use the task definition family.
5. Complete the deployment step.

## ECS task definition template

The deployment uses this template:

- `aws/task-definition-template.json`

The template contains the ECS task runtime configuration:

- task family;
- container name;
- image placeholder;
- port mapping;
- CloudWatch logs;
- execution role;
- Fargate compatibility;
- CPU and memory.

The image field uses:

- `IMAGE_URI_PLACEHOLDER`

The deploy script replaces this value with the image pushed by the current pipeline.

## Deployment script

The deploy job uses:

- `scripts/deploy-ecs.sh`

The script runs with strict shell behavior:

- stop on errors;
- fail on undefined variables;
- fail pipeline errors.

This keeps the deploy job predictable and easier to troubleshoot.

## Successful pipeline result

A successful pipeline run confirms that:

- GitLab Runner can execute the project pipeline;
- Maven tests pass;
- Checkstyle analysis runs;
- the application JAR is built;
- SonarQube Quality Gate is checked;
- Docker image build succeeds;
- the image is pushed to AWS ECR;
- a new ECS task definition revision is registered;
- ECS service is updated.
