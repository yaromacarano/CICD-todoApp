# Project Overview

## Purpose

This branch delivers a Java Spring Boot Todo application to AWS with GitHub Actions. Terraform manages the AWS infrastructure, while the workflow handles application validation, image publishing, and deployment.

The two processes are intentionally separate:

- infrastructure changes are applied manually with Terraform;
- application changes are delivered by GitHub Actions.

This means Terraform does not run before every build and the application workflow does not recreate AWS resources on every push.

## Architecture

### Infrastructure flow

```text
Local workstation
       ↓
   Terraform
       ↓
Default VPC, security groups, ALB, ECR, ECS Fargate, IAM and CloudWatch
```

### Application delivery flow

```text
GitHub repository
       ↓
GitHub Actions
       ↓
Maven, tests and Checkstyle
       ↓
SonarQube Cloud Quality Gate
       ↓
Docker image → Amazon ECR
       ↓
ECS task definition → ECS service
       ↓
Application Load Balancer
```

## Responsibilities

| Component | Responsibility |
| --- | --- |
| Terraform | Creates and updates the AWS infrastructure |
| GitHub Actions | Builds, checks, packages, and deploys the application |
| Maven | Compiles the project, runs tests, and creates the JAR |
| Checkstyle | Produces the Java style report used by the analysis |
| SonarQube Cloud | Analyses code quality and returns the Quality Gate result |
| Docker | Packages the JAR into a consistent runtime image |
| Amazon ECR | Stores versioned Docker images |
| Amazon ECS Fargate | Runs the application container without a managed EC2 server |
| Application Load Balancer | Provides the public HTTP entry point and health checks |
| CloudWatch Logs | Stores logs produced by the ECS task |

## First deployment

The first deployment requires two separate actions:

1. Run Terraform locally to create the AWS resources.
2. Start the GitHub Actions workflow manually from the `github-actions` branch.

Terraform does not automatically notify GitHub when `terraform apply` finishes. The manual workflow run builds the first application image, pushes it to the newly created ECR repository, and updates the ECS service.

After the infrastructure exists, a normal push to `github-actions` starts the complete build and deployment flow.

## Workflow behaviour

| Trigger | What happens |
| --- | --- |
| Push to `github-actions` | Build, tests, analysis, image push, and ECS deployment |
| Pull request to `github-actions` | Build, tests, and analysis without AWS deployment |
| Manual workflow run | Complete flow when the selected branch is `github-actions` |

The `deploy` job depends on the successful completion of `build-test-scan`. A failed build, test, Checkstyle execution, SonarQube Cloud analysis, or Quality Gate stops the workflow before deployment.

## AWS resources

Terraform creates:

- an ECR repository named `todo-app`;
- an ECS cluster named `newcluster`;
- an ECS Fargate service named `todo-ecs-service`;
- the initial `todo-task` task definition;
- an Application Load Balancer, target group, and HTTP listener;
- separate security groups for the load balancer and ECS tasks;
- a CloudWatch log group named `/ecs/todo-task`;
- an ECS task execution role named `ecsTaskExecutionRole`.

The configuration reuses the default VPC and its subnets. The load balancer accepts HTTP traffic on port `80` and forwards it to the application on port `8080`.

## Repository layout

| Path | Content |
| --- | --- |
| `.github/workflows/deploy.yml` | GitHub Actions CI/CD workflow |
| `terraform/` | AWS infrastructure configuration |
| `aws/task-definition-template.json` | Task definition template used for each deployment |
| `Dockerfile` and `.dockerignore` | Container build configuration |
| `pom.xml` | Maven project definition |
| `src/` | Application code and tests |
| `docs/` | Setup, architecture, deployment, and troubleshooting notes |

## Important design decisions

- GitHub-hosted runners are temporary, so no Ansible configuration is required for them.
- SonarQube Cloud removes the need to run and maintain a separate SonarQube EC2 instance.
- Terraform state is local and must be preserved outside Git.
- Terraform ignores changes to the ECS service task definition because GitHub Actions registers a new revision during every deployment.
- SQLite data is stored inside the running task and is not persistent across task replacement.

These choices keep the project understandable and economical while preserving a complete infrastructure and CI/CD flow.
