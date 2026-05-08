# Troubleshooting

## Purpose

This document contains checks for common issues in the local build, Docker image build, Jenkins pipeline, SonarQube analysis, AWS ECR push, and AWS ECS deployment trigger.

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

- `docker build -t todo-app:v1.0 .`

## Container starts but application is not available

### Check container status

Command:

- `docker ps`

### Check logs

Command:

- `docker logs <container_id>`

### Check port mapping

The application runs on port `8080`:

- `docker run --rm -p 8080:8080 todo-app:v1.0`

## Jenkins cannot find Java or Maven

Check Jenkins Global Tool Configuration.

Expected tool names:

- `JDK17`
- `MAVEN3.9`

The names must match the values used in `Jenkinsfile`.

## Jenkins cannot clone repository

Check the `Fetch code` stage.

Expected repository URL:

- `git branch: 'main', url: 'https://github.com/yaromacarano/CICD-todoApp.git'`

Also check:

- repository visibility;
- branch name;
- Jenkins network access to GitHub;
- Git installation on the Jenkins agent.

## SonarQube analysis fails

Check Jenkins SonarQube configuration.

Configured values:

- **SonarQube server:** `sonarserver`
- **SonarQube scanner:** `sonar8.0`

Also check:

- SonarQube server is running;
- Jenkins can reach the SonarQube URL;
- SonarQube token is valid;
- project key and scanner configuration are correct.

## Quality Gate stage is stuck

Check SonarQube webhook configuration.

The Jenkins Quality Gate step requires SonarQube to send the result back to Jenkins.

Check:

- SonarQube webhook URL;
- Jenkins URL reachable from SonarQube;
- SonarQube analysis completed successfully;
- Quality Gate exists in SonarQube.

## ECR push fails

Check AWS credentials in Jenkins.

Expected credentials ID:

- `awscreds`

Check AWS CLI access from the Jenkins agent:

- `aws sts get-caller-identity`

Check ECR login and repository access:

- `aws ecr describe-repositories --region us-east-1`

Common causes:

- invalid AWS credentials;
- missing ECR permissions;
- wrong AWS region;
- ECR repository does not exist;
- Docker is not authenticated to ECR.

## ECS deployment trigger fails

Current deployment command:

- `aws ecs update-service --cluster newcluster --service todo-ecs-service --force-new-deployment --region us-east-1`

Check:

- ECS cluster exists;
- ECS service exists;
- Jenkins has `ecs:UpdateService` permission;
- AWS region is correct;
- ECS task definition points to the correct ECR image;
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
