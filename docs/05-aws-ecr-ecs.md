# AWS ECR and ECS

## Purpose

This document describes the AWS part of the CI/CD workflow.

AWS ECR stores the Docker image built by Jenkins. AWS ECS runs the containerized application through an ECS service.

## AWS services used

- **AWS ECR:** stores the Docker image.
- **AWS ECS:** runs the application container.
- **IAM:** provides permissions for Jenkins to access AWS resources.

## Deployment flow

Jenkins builds the Docker image, authenticates to AWS ECR, pushes the image, creates a new ECS task definition revision from aws/task-definition-template.json, updates the ECS service to use the new revision and waits until the ECS service becomes stable.

The ECS service then starts a new deployment cycle and runs a task with the configured task definition.

## ECR configuration

The pipeline uses this image name:

- `ECR_REPOSITORY = "todo-app"`

Registry value:

- `ECR_REGISTRY = "551647579168.dkr.ecr.us-east-1.amazonaws.com"`

AWS region:

- `AWS_REGION = "us-east-1"`

## ECS configuration

The pipeline triggers deployment for this ECS service:

- `ECS_CLUSTER = "newcluster"`
- `ECS_SERVICE = "todo-ecs-service"`
- `ECS_TASK_FAMILY = "todo-task"`
- `CONTAINER_NAME = "todo"`

## ECS task definition template

- template path: `aws/task-definition-template.json`
- image placeholder: `IMAGE_URI_PLACEHOLDER`
- generated file during pipeline: `task-definition.json`

## AWS resources

The AWS environment contains:

- ECR repository: `todo-app`;
- ECS cluster: `newcluster`;
- ECS service: `todo-ecs-service`;
- ECS task definition configured with the ECR image;
- networking configuration required by the ECS service;
- IAM permissions for Jenkins.

## Jenkins AWS access

Jenkins uses AWS credentials stored in Jenkins Credentials.

Credential ID used by the pipeline:

- `awscreds`

The Jenkins credentials include permissions for:

- ECR authentication;
- ECR image push;
- ECS service update;
- ECS service and cluster description if required by the environment.

## IAM permission areas

The Jenkins IAM user or role uses access to these AWS API areas:

- `ecr:GetAuthorizationToken`
- `ecr:BatchCheckLayerAvailability`
- `ecr:InitiateLayerUpload`
- `ecr:UploadLayerPart`
- `ecr:CompleteLayerUpload`
- `ecr:PutImage`
- `ecs:UpdateService`
- `ecs:DescribeServices`
- `ecs:DescribeClusters`
- `ecs:RegisterTaskDefinition`
- `ecs:DescribeTaskDefinition`
- `iam:PassRole`

## Deployment verification

After a successful Jenkins run, the AWS console shows:

- a new or updated image in ECR;
- ECS service deployment activity;
- running ECS task;
- task definition using the ECR image;
- application available through the configured ECS endpoint or load balancer.

## Security notes

AWS credentials are not stored in the repository.

Sensitive values such as access keys, secret keys, tokens, and passwords are managed outside the repository through Jenkins Credentials and AWS IAM.
