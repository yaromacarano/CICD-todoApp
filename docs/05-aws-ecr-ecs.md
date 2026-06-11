# AWS ECR and ECS

## Purpose

This document describes the AWS part of the GitHub Actions CI/CD workflow.

AWS ECR stores the Docker image built by GitHub Actions. AWS ECS runs the containerized application through an ECS service.

## AWS services used

- **AWS ECR:** stores the Docker image.
- **AWS ECS:** runs the application container.
- **AWS IAM:** provides permissions for GitHub Actions to access AWS resources.
- **AWS CloudWatch Logs:** stores logs from the ECS task.

## Deployment flow

GitHub Actions builds the Docker image, authenticates to AWS ECR, pushes the image, renders a new ECS task definition, and deploys it to the ECS service.

Deployment flow:

1. GitHub Actions configures AWS credentials.
2. The workflow logs in to AWS ECR.
3. The Docker image is built from the repository `Dockerfile`.
4. The image is tagged with the GitHub Actions run number and the short commit SHA.
5. The image is pushed to AWS ECR.
6. The workflow renders `aws/task-definition-template.json` with the new image.
7. AWS ECS receives a new task definition revision.
8. The ECS service is updated to use the new task definition.
9. The workflow waits until the ECS service becomes stable.

## ECR configuration

The ECR repository name is stored in GitHub Actions Variable:

- `ECR_REPOSITORY`

The AWS region is stored in GitHub Actions Variable:

- `AWS_REGION`

The final image URI is created during the workflow from:

- ECR registry returned by the ECR login action;
- ECR repository variable;
- GitHub Actions run number.

Image format:

- `IMAGE_TAG="${GITHUB_RUN_NUMBER}-${GITHUB_SHA::7}"`

## ECS configuration

The workflow deploys to ECS using these GitHub Actions Variables:

- `CLUSTER` — ECS cluster name.
- `SERVICE` — ECS service name.
- `CONTAINER_NAME` — container name inside the ECS task definition.

The ECS task definition template is stored in:

- `aws/task-definition-template.json`

## ECS task definition template

The task definition template contains the runtime configuration for the ECS task:

- task family;
- container name;
- container port mapping;
- CPU and memory;
- Fargate compatibility;
- CloudWatch logs configuration;
- ECS execution role;
- container image field.

During deployment, GitHub Actions renders the template and replaces the container image with the new ECR image.

## AWS resources

The AWS environment contains:

- ECR repository for the application image;
- ECS cluster;
- ECS service;
- ECS task definition configured for Fargate;
- networking configuration required by the ECS service;
- IAM permissions for GitHub Actions;
- CloudWatch log group for ECS task logs.

## GitHub Actions AWS access

GitHub Actions uses AWS credentials stored in GitHub Actions Secrets.

Required secrets:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

The workflow does not store AWS access keys in the repository.

## IAM permission areas

The AWS IAM user or role used by GitHub Actions needs access to these AWS API areas:

- `ecr:GetAuthorizationToken`
- `ecr:BatchCheckLayerAvailability`
- `ecr:InitiateLayerUpload`
- `ecr:UploadLayerPart`
- `ecr:CompleteLayerUpload`
- `ecr:PutImage`
- `ecs:RegisterTaskDefinition`
- `ecs:DescribeTaskDefinition`
- `ecs:UpdateService`
- `ecs:DescribeServices`
- `iam:PassRole`

`iam:PassRole` is required because ECS task definitions use an execution role.

## Deployment verification

After a successful GitHub Actions run, the AWS console shows:

- a new image in ECR with a tag based on the GitHub Actions run number and short commit SHA;
- a new ECS task definition revision;
- ECS service deployment activity;
- running ECS task;
- ECS service using the latest task definition revision;
- application available through the configured ECS endpoint or load balancer.

## Security notes

AWS credentials are not stored in the repository.

Sensitive values such as access keys, secret keys, tokens, and passwords are managed outside the repository through GitHub Actions Secrets and AWS IAM.

Screenshots must not expose AWS access keys, secret values, tokens, or private infrastructure details.
