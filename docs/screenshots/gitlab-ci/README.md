# GitLab CI Screenshots

## Purpose

This directory stores screenshots that prove the GitLab CI/CD pipeline and AWS deployment are working.

Recommended path:

- `docs/screenshots/gitlab-ci/`

## Screenshots

### 1. GitLab branch or project overview

Filename:

- `01-gitlab-ci-branch-overview.jpg`

Visible details:

- project or branch name;
- repository files;
- `.gitlab-ci.yml`;
- `aws/`;
- `scripts/`;
- `Dockerfile`;
- `README.md`.

### 2. GitLab CI pipeline file

Filename:

- `02-gitlab-ci-pipeline-file.jpg`

Visible details:

- `.gitlab-ci.yml`;
- stages section;
- job names;
- deploy stage;
- branch rules if visible.

### 3. Successful GitLab pipeline run

Filename:

- `03-gitlab-ci-pipeline-success.jpg`

Visible details:

- pipeline status passed;
- branch name;
- commit SHA or pipeline number;
- stages completed successfully.

### 4. GitLab CI job stages

Filename:

- `04-gitlab-ci-job-stages.jpg`

Visible details:

- `test`;
- `build`;
- `sonarqube-check`;
- `push`;
- `deploy`.

### 5. SonarQube project overview

Filename:

- `05-sonarqube-project-overview.jpg`

Visible details:

- project name;
- latest analysis;
- bugs;
- vulnerabilities;
- code smells;
- duplications;
- coverage if available.

### 6. SonarQube Quality Gate

Filename:

- `06-sonarqube-quality-gate.jpg`

Visible details:

- Quality Gate status;
- Passed result;
- main metrics.

### 7. ECR image from GitLab CI

Filename:

- `07-ecr-image-from-gitlab-ci.jpg`

Visible details:

- ECR repository;
- image tag from `CI_PIPELINE_IID`;
- push time;
- image size.

### 8. ECS new task definition revision

Filename:

- `08-ecs-new-task-definition-revision.jpg`

Visible details:

- task definition family `todo-task`;
- newest revision;
- container image from ECR;
- port mapping.

### 9. ECS service updated from GitLab CI

Filename:

- `09-ecs-service-updated-from-gitlab-ci.jpg`

Visible details:

- ECS service name;
- active deployment;
- task definition revision;
- desired and running tasks;
- deployment status.

### 10. ECS task running

Filename:

- `10-ecs-task-running.jpg`

Visible details:

- task status `Running`;
- task definition revision;
- container status;
- launch type.

### 11. Application running after GitLab CI deployment

Filename:

- `11-application-running-after-gitlab-ci-deploy.jpg`

Visible details:

- application opened in browser;
- application running through the ECS endpoint or load balancer;
- Todo App page loaded successfully.

## Screenshots used in README

The main README can show only the strongest proof points:

- `03-gitlab-ci-pipeline-success.jpg`
- `04-gitlab-ci-job-stages.jpg`
- `06-sonarqube-quality-gate.jpg`
- `07-ecr-image-from-gitlab-ci.jpg`
- `09-ecs-service-updated-from-gitlab-ci.jpg`
- `11-application-running-after-gitlab-ci-deploy.jpg`

## Safety checklist

Before committing screenshots, hide:

- AWS account ID;
- access keys;
- secret keys;
- tokens;
- private URLs if needed;
- personal data;
- infrastructure details that should not be public.
