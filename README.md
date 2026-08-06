# CI/CD Todo App — GitLab CI, Terraform and Ansible

Spring Boot Todo application deployed to AWS ECS Fargate through a self-hosted GitLab CI pipeline.

## Stack

- Java 21 and Maven
- GitLab CI/CD and self-hosted GitLab Runner
- Docker and Docker-in-Docker
- SonarQube Cloud
- Terraform and Ansible
- AWS EC2, IAM, ECR, ECS Fargate, ALB and CloudWatch Logs

## Architecture

1. Terraform creates the AWS infrastructure and a dedicated IAM user for GitLab CI.
2. Ansible configures the GitLab Runner on EC2.
3. GitLab CI tests the application and runs SonarQube Cloud analysis.
4. The pipeline builds a Docker image and pushes it to ECR.
5. The deployment script registers a new ECS task revision and updates the ECS service.

AWS credentials are stored only in GitLab CI/CD variables. `terraform.tfstate` contains the generated Secret Key and must remain private.

## Pipeline

| Stage | Job | Result |
| --- | --- | --- |
| `test` | `test-job` | Tests and Checkstyle report |
| `build` | `build-job` | Application JAR |
| `sonarqube-check` | `sonarqube-check-job` | SonarQube Cloud Quality Gate |
| `push` | `push-image-job` | Docker image in ECR |
| `deploy` | `deploy-ecs-job` | New ECS task revision |

Validation runs for `main`, `develop`, merge requests, schedules and manual pipelines. AWS deployment runs only from `main`.

## Quick start

1. Configure and apply Terraform.
2. Create a Project Runner in GitLab.
3. Configure the Runner with Ansible.
4. Create a SonarQube Cloud project.
5. Add AWS, ECS and SonarQube variables to GitLab.
6. Push the project to `main`.

Full setup: [`docs/07-terraform-ansible.md`](docs/07-terraform-ansible.md)

## GitLab CI/CD variables

| Group | Variables |
| --- | --- |
| AWS secrets | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` |
| AWS deployment | `AWS_DEFAULT_REGION`, `ECR_REPOSITORY_URL`, `ECS_CLUSTER`, `ECS_SERVICE`, `ECS_TASK_FAMILY`, `ECS_TASK_EXECUTION_ROLE_ARN`, `ECS_LOG_GROUP`, `APPLICATION_URL` |
| SonarQube Cloud | `SONAR_TOKEN`, `SONAR_ORGANIZATION`, `SONAR_PROJECT_KEY` |

Mark `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` and `SONAR_TOKEN` as **Masked**. Use **Protected** only when `main` is protected.

## Documentation

- [`01-project-overview.md`](docs/01-project-overview.md) — architecture and responsibilities
- [`02-local-run.md`](docs/02-local-run.md) — local Java run
- [`03-docker.md`](docs/03-docker.md) — local Docker run
- [`04-gitlab-ci-pipeline.md`](docs/04-gitlab-ci-pipeline.md) — pipeline and variables
- [`05-aws-ecr-ecs.md`](docs/05-aws-ecr-ecs.md) — AWS resources and deployment
- [`06-troubleshooting.md`](docs/06-troubleshooting.md) — common errors
- [`07-terraform-ansible.md`](docs/07-terraform-ansible.md) — complete setup

## Cleanup

```bash
cd terraform
terraform destroy
```

EC2, ECS Fargate, ALB, storage and network traffic can generate AWS charges.
