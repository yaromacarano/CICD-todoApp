# AWS ECR and ECS

## Purpose

This document describes the AWS part of the GitLab CI/CD workflow.

AWS ECR stores the Docker image built by GitLab CI. AWS ECS runs the containerized application through an ECS service.

## AWS services used

- **AWS ECR:** stores the Docker image.
- **AWS ECS:** runs the application container.
- **AWS IAM:** provides permissions for GitLab CI to access AWS resources.
- **AWS CloudWatch Logs:** stores ECS container logs.

## Deployment flow

GitLab CI builds the Docker image, authenticates to AWS ECR, pushes the image, creates a new ECS task definition revision, and updates the ECS service.

The ECS service then starts a deployment with the updated task definition and runs a task using the new image.

AWS deployment commands are executed from the self-hosted GitLab Runner hosted on AWS EC2. The runner is selected by the default tags in `.gitlab-ci.yml`: `aws`, `docker`, and `ec2`.

## ECR configuration

The pipeline uses GitLab CI/CD variables for ECR configuration:

- `ECR_REGISTRY` — ECR registry URL.
- `ECR_REPOSITORY` — ECR repository name.
- `IMAGE_TAG` — pipeline image tag based on `CI_PIPELINE_IID`.
- `IMAGE_URI` — full Docker image URI used for build, push, and ECS deployment.

Image format:

- `$ECR_REGISTRY/$ECR_REPOSITORY:$CI_PIPELINE_IID`

## ECS configuration

The pipeline uses GitLab CI/CD variables for ECS configuration:

- `ECS_CLUSTER` — ECS cluster name.
- `ECS_SERVICE` — ECS service name.
- `ECS_TASK_FAMILY` — ECS task definition family name.
- `AWS_DEFAULT_REGION` — AWS region used by the AWS CLI.

The deployment script registers a new task definition revision and updates the ECS service.

## ECS task definition template

The project stores the ECS task definition template in:

- `aws/task-definition-template.json`

The template contains:

- task family;
- container definition;
- ECR image placeholder;
- port mapping for port `8080`;
- CloudWatch logs configuration;
- execution role;
- Fargate compatibility;
- CPU and memory values.

The image field uses:

- `IMAGE_URI_PLACEHOLDER`

During deployment, `scripts/deploy-ecs.sh` replaces this placeholder with the image URI from the current pipeline.

Generated file:

- `aws/task-definition.json`

## Deployment script

The deployment command is stored in:

- `scripts/deploy-ecs.sh`

The script performs these actions:

1. Prepare ECS task definition from template.
2. Register a new ECS task definition revision.
3. Update the ECS service to use the configured task definition family.

## GitLab AWS access

GitLab CI uses AWS credentials stored as GitLab CI/CD variables.

Required AWS variables:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_DEFAULT_REGION`

These values are not stored in the repository.

## IAM permission areas

The GitLab CI AWS user or role needs access to these AWS API areas:

- `ecr:GetAuthorizationToken`
- `ecr:BatchCheckLayerAvailability`
- `ecr:InitiateLayerUpload`
- `ecr:UploadLayerPart`
- `ecr:CompleteLayerUpload`
- `ecr:PutImage`
- `ecs:RegisterTaskDefinition`
- `ecs:UpdateService`
- `ecs:DescribeServices`
- `ecs:DescribeTaskDefinition`
- `ecs:DescribeClusters`
- `iam:PassRole`

`iam:PassRole` is required because the ECS task definition uses an execution role.

## Deployment verification

After a successful GitLab CI run, the AWS console shows:

- a new image tag in ECR;
- a new ECS task definition revision;
- ECS service deployment activity;
- running ECS task;
- task definition using the pushed ECR image;
- application available through the configured ECS endpoint or load balancer.

## Security notes

AWS credentials are not stored in the repository.

Sensitive values such as access keys, secret keys, tokens, passwords, AWS account details, and private infrastructure information are managed through GitLab CI/CD variables and AWS IAM.
