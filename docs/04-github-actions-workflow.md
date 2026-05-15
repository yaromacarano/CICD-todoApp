# GitHub Actions Workflow

## Purpose

This document explains the CI/CD workflow defined in `.github/workflows/deploy.yml`.

The workflow automates the flow from source code checkout to AWS ECS deployment using GitHub Actions.

## Workflow overview

Checkout code → Set up Java 17 → Maven verification → Checkstyle analysis → Maven package → SonarQube analysis → Artifact upload → AWS authentication → ECR image push → ECS task definition render → ECS deployment → Service stability check

## Workflow triggers

The workflow runs on:

- push to `github-actions`;
- pull request to `github-actions`;
- manual start through `workflow_dispatch`.

Deployment to AWS runs only on direct pushes to the `github-actions` branch.

Pull requests run the build and quality stages without deploying to AWS.

## GitHub Actions permissions

The workflow uses:

- `contents: read`

This allows the workflow to read repository content during checkout.

## Runner

The workflow uses a GitHub-hosted runner:

- `ubuntu-latest`

The runner is created fresh for every workflow run.

## Environment

The workflow uses the GitHub environment:

- `production`

This groups deployment-related settings and can be used for environment protection rules.

## GitHub Secrets

The workflow uses GitHub Actions Secrets for sensitive values.

Required secrets:

- `AWS_ACCESS_KEY_ID` — AWS access key used by GitHub Actions.
- `AWS_SECRET_ACCESS_KEY` — AWS secret key used by GitHub Actions.
- `SONAR_TOKEN` — token used to authenticate with SonarQube.
- `SONAR_HOST_URL` — public SonarQube URL used by the GitHub-hosted runner.

Secrets are not stored in the repository.

## GitHub Variables

The workflow uses GitHub Actions Variables for environment-specific values.

Required variables:

- `AWS_REGION` — AWS region used for ECR and ECS.
- `ECR_REPOSITORY` — ECR repository name.
- `CONTAINER_NAME` — ECS container name used in the task definition.
- `SERVICE` — ECS service name.
- `CLUSTER` — ECS cluster name.

These values are configuration, not application code.

## Workflow steps

### 1. Checkout code

Checks out the repository code on the GitHub-hosted runner.

The workflow uses `fetch-depth: 0` so the full Git history is available for code analysis.

### 2. Setup JDK 17

Installs Java 17 using the Temurin distribution.

The workflow also enables Maven dependency caching.

### 3. Run Unit Tests

Runs Maven verification:

- `mvn clean verify`

This checks that the project can be compiled and verified through Maven.

### 4. Checkstyle Analysis

Runs Checkstyle analysis through Maven:

- `mvn checkstyle:checkstyle`

This creates the Checkstyle report used by the quality analysis step.

### 5. Build application

Builds the application package without running tests again:

- `mvn package -DskipTests`

The build creates the application JAR in the `target/` directory.

### 6. Sonar Code Analysis

Runs SonarQube analysis using the configured SonarQube token and server URL.

The analysis sends code quality data to SonarQube and waits for the Quality Gate result.

Important values:

- project key: `todo-sonar`
- source directory: `src/`
- Java binaries: `target/classes/`
- Checkstyle report: `target/checkstyle-result.xml`
- Quality Gate wait: enabled

### 7. Upload artifact

Uploads the built JAR as a GitHub Actions artifact.

Artifact name:

- `todolist-app-1.0.0`

Artifact path:

- `target/*.jar`

### 8. Configure AWS Credentials

Configures AWS credentials for the deployment steps.

This step runs only for direct pushes to `github-actions`, not for pull requests.

### 9. Login to Amazon ECR

Authenticates Docker to AWS ECR.

The action returns the ECR registry URL used in the Docker image name.

### 10. Build, tag and push image to ECR

Builds the Docker image from the repository `Dockerfile`.

The image tag uses the GitHub Actions run number:

- `github.run_number`

The image URI is saved as workflow output and passed to the ECS deployment steps.

### 11. Render ECS task definition

Uses the ECS task definition template from:

- `aws/task-definition-template.json`

The workflow replaces the container image with the newly pushed ECR image.

The container name is loaded from GitHub Actions Variable `CONTAINER_NAME`.

### 12. Deploy ECS task definition

Deploys the rendered ECS task definition to the configured ECS service and cluster.

The deployment waits until the ECS service becomes stable.

## Successful workflow result

A successful workflow run confirms that:

- GitHub Actions can check out the repository;
- Java 17 and Maven build steps work on a clean runner;
- Checkstyle analysis runs;
- SonarQube analysis and Quality Gate pass;
- the application JAR is built and uploaded as an artifact;
- Docker image build succeeds;
- the image is pushed to AWS ECR;
- ECS receives a new task definition revision;
- ECS service is updated and becomes stable.
