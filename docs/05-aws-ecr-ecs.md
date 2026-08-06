# AWS ECR and ECS

## Purpose

Terraform creates the AWS resources used by the application. GitHub Actions publishes each new Docker image to Amazon ECR and updates the Amazon ECS service to run it.

The infrastructure and application deployment have different owners:

| Responsibility | Tool |
| --- | --- |
| Create ECR, ECS, ALB, security groups, IAM execution role, and logs | Terraform |
| Build and push an application image | GitHub Actions |
| Register a new task definition revision | GitHub Actions |
| Update the ECS service to the new revision | GitHub Actions |

## AWS resources

| Resource | Current name or configuration |
| --- | --- |
| Region | `us-east-1` |
| ECR repository | `todo-app` |
| ECS cluster | `newcluster` |
| ECS service | `todo-ecs-service` |
| Task definition family | `todo-task` |
| Container | `todo` on port `8080` |
| Launch type | Fargate |
| CloudWatch log group | `/ecs/todo-task` |
| Load balancer | `todo-ELB` on port `80` |
| Target group | `todo-target-group` on port `8080` |
| ECS task execution role | `ecsTaskExecutionRole` |

## Network flow

```text
Internet → ALB port 80 → ECS task port 8080
```

The load balancer security group accepts public HTTP traffic. The ECS security group accepts port `8080` only from the load balancer security group.

The ECS task receives a public IP because the configuration uses the default VPC without a NAT gateway. Users still access the application through the load balancer.

## Image publishing

The workflow builds the image after the build and Quality Gate pass.

The image tag is the GitHub Actions run number:

```text
AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/todo-app:GITHUB_RUN_NUMBER
```

This provides a direct connection between a workflow run and the image it deployed.

To verify a push in the AWS Console:

1. Open **Amazon ECR**.
2. Open the `todo-app` repository.
3. Confirm that a new image tag matches the GitHub Actions run number.

## Task definition deployment

The repository contains `aws/task-definition-template.json`. The workflow replaces its image placeholder with the new ECR image and registers a new revision of `todo-task`.

The template defines:

- Fargate compatibility;
- Linux on x86-64;
- `1024` CPU units;
- `3072` MiB of memory;
- container port `8080`;
- the `ecsTaskExecutionRole` execution role;
- CloudWatch Logs configuration.

After registering the revision, GitHub Actions updates `todo-ecs-service` and waits for the service to become stable.

## Load balancer health

The target group checks the application root path `/`. Status codes from `200` through `399` are considered healthy.

To verify deployment in the AWS Console:

1. Open **Amazon ECS** and select `newcluster`.
2. Open `todo-ecs-service`.
3. Check that one task is running.
4. Open the **Deployments** or **Events** section and confirm that the latest deployment completed.
5. Open the target group and confirm that the task target is healthy.
6. Open the Terraform `application_url` output in a browser.

## CloudWatch logs

Application logs are sent to:

```text
/ecs/todo-task
```

If a task stops or the target becomes unhealthy, open the latest log stream in CloudWatch Logs before changing the infrastructure.

## AWS access used by GitHub Actions

Terraform creates the ECS task execution role used by the running task. It does not create the IAM user or access keys used by GitHub Actions.

The GitHub Actions AWS identity needs permission to:

- authenticate and push images to ECR;
- register and describe ECS task definitions;
- update and describe the ECS service;
- pass `ecsTaskExecutionRole` to ECS.

The exact permission list depends on whether the project uses an IAM user or role. AWS credentials are stored in GitHub Secrets and never in the repository.

## Terraform and ECS revisions

Terraform creates the initial ECS task definition and service. GitHub Actions then registers a new task definition revision on every deployment.

The Terraform ECS service resource uses:

```hcl
lifecycle {
  ignore_changes = [task_definition]
}
```

Without this rule, a later `terraform apply` could change the service back to the original Terraform revision. Terraform continues to manage the service itself but leaves the deployed application revision under GitHub Actions control.

## First-image behaviour

The initial Terraform task definition points to the `latest` image in the new ECR repository. If the repository is empty, ECS may show a stopped task until the first GitHub Actions deployment pushes a real image and registers a new revision.

For the first deployment:

1. create the infrastructure with Terraform;
2. configure the GitHub Secrets and Variables;
3. push a commit to the `github-actions` branch;
4. wait for the ECS deployment to become stable.

If there are no file changes to commit, use an empty commit to start the workflow:

```bash
git switch github-actions
git commit --allow-empty -m "ci: trigger first deployment"
git push origin github-actions
```

## Cost considerations

The main running costs come from the Application Load Balancer and the Fargate task. ECR also charges for stored images after any free allowance.

When the environment is only needed temporarily, remove old images and run `terraform destroy` after the demonstration. See [Terraform Infrastructure](07-terraform.md) for the cleanup sequence.
