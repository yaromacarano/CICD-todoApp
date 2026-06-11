# Jenkins Pipeline

## Purpose

This document explains the CI/CD pipeline defined in `Jenkinsfile`.

The pipeline automates the flow from source code checkout to AWS ECS deployment trigger.

## Pipeline overview

Fetch code → Maven verification → Checkstyle analysis → SonarQube analysis → Quality Gate → Maven package → Docker image build → Docker image push to ECR → ECS service deployment trigger

## Jenkins tools

The pipeline uses these Jenkins tool names:

- **JDK:** `JDK21`
- **Maven:** `MAVEN3.9`
- **SonarQube scanner:** `sonar8.0`

The tool names in Jenkins must match the values used in `Jenkinsfile`.


## Jenkins plugins

The Jenkins pipeline requires plugins for Pipeline syntax, GitHub checkout, Maven integration, SonarQube analysis, Docker image build/push, AWS authentication and ECS deployment commands.

Installed plugins for this setup:

- **Pipeline** — core Pipeline functionality for running the `Jenkinsfile`.
- **Pipeline Maven Integration Plugin** — Maven build support inside Jenkins Pipeline.
- **GitHub Branch Source Plugin** — GitHub repository and branch integration.
- **Pipeline: GitHub Groovy Libraries** — GitHub-based shared library support for Pipeline jobs.
- **SonarQube Scanner for Jenkins** — SonarQube scanner configuration and Quality Gate integration.
- **Amazon ECR plugin** — AWS ECR authentication support for Docker image push.
- **Pipeline: AWS Steps** — AWS-related Pipeline steps and credential handling.
- **Amazon Web Services SDK :: All** — AWS SDK dependencies used by AWS-related Jenkins plugins.
- **Docker Pipeline** — Docker commands and image operations inside Jenkins Pipeline.
- **CloudBees Docker Build and Publish plugin** — Docker image build and publish support.
- **Build Timestamp Plugin** — build timestamp variables for logs and build metadata.
- **Workspace Cleanup Plugin** — workspace cleanup before or after pipeline runs.

These plugins support the current pipeline stages from GitHub checkout to Docker image delivery and AWS ECS deployment trigger.

## Jenkins integrations

- **SonarQube server:** `sonarserver`
- **AWS credentials ID:** `awscreds`
- **Docker registry credentials:** configured for AWS ECR push
- **Docker CLI:** available on the Jenkins agent
- **AWS CLI:** available on the Jenkins agent

## Repository checkout

The `Fetch code` stage clones the repository from GitHub.

Current repository URL:

- `git branch: 'main', url: 'https://github.com/yaromacarano/CICD-todoApp.git'`

## Environment values

The pipeline uses these AWS and deployment values from the `environment` block:

- `registryCredential = "ecr:us-east-1:awscreds"`
- `imageName = credentials('ecr-image-name')`
- `Registry = "https://551647579168.dkr.ecr.us-east-1.amazonaws.com"`
- `service = "todo-ecs-service"`
- `taskDefinition = "todo-task"`
- `containerName = "todo"`
- `cluster = "newcluster"`

## Pipeline stages

### 1. VERIFY AGENT

Checks that the Jenkins agent has the required tools installed: Java, Maven, Git, Docker, and AWS CLI.

### 2. Fetch code

Clones the source code from GitHub.

This stage confirms that Jenkins can access the repository and branch.

### 3. UNIT TEST

Runs Maven verification:

- `mvn clean verify`

This stage checks that the project can be compiled and verified through Maven.

### 4. Checkstyle Analysis

Runs Checkstyle analysis through Maven.

The stage produces a style/static analysis report for the Java codebase.

### 5. Sonar Code Analysis

Runs SonarQube analysis with the configured SonarQube scanner and server.

This stage sends code quality data to SonarQube.

### 6. Quality Gate

Waits for the SonarQube Quality Gate result.

The pipeline continues only after the quality gate result is received.

### 7. Build

Builds the application artifact:

- `mvn clean package`

Application artifact:

- `target/todolist-app-1.0.0.jar`

### 8. Build App Image

Builds the Docker image using the repository `Dockerfile`.

The image is prepared for upload to AWS ECR.

### 9. Upload App Image

Authenticates to AWS ECR and pushes the Docker image.

This stage confirms that Jenkins has valid AWS and Docker registry access.

### 10. Deploy to ECS

Triggers a new deployment of the configured ECS service:

- Jenkins builds `IMAGE_URI` from imageName and `BUILD_NUMBER`;
- Jenkins replaces `IMAGE_URI_PLACEHOLDER` in aws/task-definition-template.json;
- Jenkins creates task-definition.json;
- Jenkins registers a new ECS task definition revision;
- Jenkins updates ECS service to the new revision;
- Jenkins waits until ECS service is stable.

This makes ECS start a new deployment cycle for the service.

## Successful pipeline result

A successful pipeline run confirms that:

- Jenkins can clone the repository;
- Maven verification passes;
- static analysis stages run;
- SonarQube Quality Gate is checked;
- the application JAR is built;
- Docker image build succeeds;
- the image is pushed to AWS ECR;
- ECS task definition revision registration;
- ECS service update;
- ECS service stability check.
