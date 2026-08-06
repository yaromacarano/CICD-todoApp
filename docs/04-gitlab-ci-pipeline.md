# GitLab CI Pipeline

## Runner

The self-hosted Runner uses the Docker executor and these tags:

- `aws`
- `docker`
- `ec2`

In GitLab, assign the Runner only to this project and disable **Run untagged jobs**.

## Jobs

| Job | Action | Output |
| --- | --- | --- |
| `test-job` | Tests and Checkstyle | Classes and reports |
| `build-job` | Maven package | JAR and reports |
| `sonarqube-check-job` | SonarQube Cloud scan | Quality Gate result |
| `push-image-job` | Docker build and ECR push | Versioned image |
| `deploy-ecs-job` | ECS update | New task revision |

`build-job` does not run `clean` because it receives test reports from `test-job` for SonarQube analysis.

## Rules

| Pipeline source | Test and build | SonarQube | AWS deploy |
| --- | --- | --- | --- |
| `main` | Yes | Yes | Yes |
| `develop` | Yes | Yes | No |
| Merge request | Yes | Yes | No |
| Schedule | Yes | No | No |
| Manual web run | Yes | No | No |

## Variables

| Variable | Source |
| --- | --- |
| `AWS_ACCESS_KEY_ID` | `terraform output -raw gitlab_aws_access_key_id` |
| `AWS_SECRET_ACCESS_KEY` | `terraform output -raw gitlab_aws_secret_access_key` |
| `AWS_DEFAULT_REGION` | `terraform.tfvars` |
| `ECR_REPOSITORY_URL` | `terraform output -raw ecr_repository_url` |
| `ECS_CLUSTER` | `terraform output -raw ecs_cluster_name` |
| `ECS_SERVICE` | `terraform output -raw ecs_service_name` |
| `ECS_TASK_FAMILY` | `terraform output -raw ecs_task_family` |
| `ECS_TASK_EXECUTION_ROLE_ARN` | `terraform output -raw ecs_task_execution_role_arn` |
| `ECS_LOG_GROUP` | `terraform output -raw ecs_log_group` |
| `APPLICATION_URL` | `terraform output -raw application_url` |
| `SONAR_ORGANIZATION` | SonarQube Cloud |
| `SONAR_PROJECT_KEY` | SonarQube Cloud |
| `SONAR_TOKEN` | SonarQube Cloud |

Mark both AWS keys and `SONAR_TOKEN` as **Masked**. Mark them as **Protected** only when `main` is protected.

## Deployment

`push-image-job` authenticates to ECR, then builds and pushes `$IMAGE_URI`.

`deploy-ecs-job`:

1. verifies the AWS identity;
2. makes `scripts/deploy-ecs.sh` executable;
3. renders `aws/task-definition.json`;
4. registers a task definition revision;
5. updates the ECS service;
6. waits for service stability.
