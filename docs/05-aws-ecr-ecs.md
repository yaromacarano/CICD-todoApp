# AWS ECR and ECS

Terraform owns the AWS infrastructure, while Jenkins owns application delivery. Each successful Pipeline run publishes a new image to ECR, registers a new ECS task definition revision, and updates the running service.

## AWS services used

- **EC2:** runs Jenkins Controller, Jenkins Agent, Ansible Controller, and SonarQube.
- **ECR:** stores application Docker images.
- **ECS Fargate:** runs the application container.
- **Application Load Balancer:** exposes the application over HTTP.
- **IAM:** provides the ECS Task Execution Role and Jenkins deployment permissions.
- **CloudWatch Logs:** stores ECS container logs.
- **VPC and Security Groups:** control network access between project components.

## Deployment flow

1. Jenkins builds the Spring Boot JAR.
2. Jenkins builds a Docker image tagged with the Jenkins build number.
3. Jenkins authenticates to ECR with the credential `awscreds`.
4. Jenkins pushes the image to the `todo-app` repository.
5. Jenkins replaces `IMAGE_URI_PLACEHOLDER` in `aws/task-definition-template.json`.
6. Jenkins registers a new `todo-task` task definition revision.
7. Jenkins updates `todo-ecs-service` to use the new revision.
8. Jenkins waits until the ECS service becomes stable.
9. The Application Load Balancer routes traffic to the healthy ECS task.

## Terraform-managed resources

Terraform creates:

- ECR repository `todo-app`;
- ECS cluster `newcluster`;
- ECS task definition family `todo-task`;
- ECS service `todo-ecs-service`;
- CloudWatch log group `/ecs/todo-task`;
- Application Load Balancer, target group, and HTTP listener;
- Security Group for the load balancer;
- Security Group for ECS tasks;
- IAM role `ecsTaskExecutionRole`.

Terraform also creates the four EC2 instances and their Security Groups. They are described in `docs/07-terraform-ansible.md`.

## ECR configuration

| Setting | Value |
|---|---|
| AWS region | `us-east-1` |
| Repository | `todo-app` |
| Registry | `551647579168.dkr.ecr.us-east-1.amazonaws.com` |
| Image tag | Jenkins `BUILD_NUMBER` |

The ECR repository uses mutable tags. Image scanning on push is disabled in the current Terraform configuration.

`force_delete` is `false`, so Terraform cannot delete a non-empty repository during `terraform destroy`.

## ECS configuration

| Setting | Value |
|---|---|
| Cluster | `newcluster` |
| Service | `todo-ecs-service` |
| Task definition family | `todo-task` |
| Container name | `todo` |
| Container port | `8080` |
| Launch type | Fargate |
| CPU | `1024` |
| Memory | `3072` MiB |
| Desired task count | `1` |
| CloudWatch log group | `/ecs/todo-task` |

The ECS task uses `awsvpc` networking and receives a public IP in the current network design.

The ECS Security Group accepts port `8080` only from the Application Load Balancer Security Group.

## ECS task definition template

Jenkins uses:

```text
aws/task-definition-template.json
```

The template contains:

```text
IMAGE_URI_PLACEHOLDER
```

During deployment, `scripts/deploy-ecs.sh` replaces the placeholder and creates a temporary file:

```text
task-definition.json
```

The generated file is ignored by Git.

The template uses this execution role:

```text
arn:aws:iam::551647579168:role/ecsTaskExecutionRole
```

When deploying into another AWS account, replace the account ID in the template.

## Terraform and Jenkins task definition revisions

Terraform creates the initial task definition and ECS service.

After each successful build, Jenkins creates a newer task definition revision. The Terraform ECS service resource contains:

```hcl
lifecycle {
  ignore_changes = [task_definition]
}
```

This prevents a later `terraform apply` from moving the ECS service back to the original Terraform-created revision.

## Jenkins AWS credentials

Use a dedicated IAM user such as:

```text
jenkins-cicd
```

Create an access key for that user and store it in Jenkins as an **AWS Credentials** credential with this exact ID:

```text
awscreds
```

Do not store the access key or secret key in this repository.

## Jenkins IAM policy

Attach a least-privilege policy based on the following example:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EcrAuthorization",
      "Effect": "Allow",
      "Action": "ecr:GetAuthorizationToken",
      "Resource": "*"
    },
    {
      "Sid": "EcrImagePush",
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage"
      ],
      "Resource": "arn:aws:ecr:us-east-1:ACCOUNT_ID:repository/todo-app"
    },
    {
      "Sid": "EcsDeployment",
      "Effect": "Allow",
      "Action": [
        "ecs:RegisterTaskDefinition",
        "ecs:DescribeTaskDefinition",
        "ecs:UpdateService",
        "ecs:DescribeServices"
      ],
      "Resource": "*"
    },
    {
      "Sid": "PassEcsExecutionRole",
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "arn:aws:iam::ACCOUNT_ID:role/ecsTaskExecutionRole",
      "Condition": {
        "StringEquals": {
          "iam:PassedToService": "ecs-tasks.amazonaws.com"
        }
      }
    }
  ]
}
```

Replace `ACCOUNT_ID` with the value returned locally from the `terraform/` directory:

```bash
terraform output -raw aws_account_id
```

The `ecs:DescribeServices` permission is required by `aws ecs wait services-stable` in the deployment script.

## ECS Task Execution Role

Terraform creates `ecsTaskExecutionRole` and attaches the AWS-managed policy:

```text
service-role/AmazonECSTaskExecutionRolePolicy
```

ECS uses this role to pull the image from ECR and send container logs to CloudWatch.

The Jenkins IAM user does not use this role directly. Jenkins only needs permission to pass it to ECS through `iam:PassRole`.

## Deployment verification

After a successful Jenkins run, verify:

1. ECR contains a new image tagged with the Jenkins build number.
2. ECS contains a new `todo-task` revision.
3. `todo-ecs-service` uses the new revision.
4. The ECS task is running and healthy.
5. CloudWatch contains a log stream under `/ecs/todo-task`.
6. The application opens through:

```bash
terraform output -raw application_url
```

## Data persistence

The application stores SQLite data at:

```text
/app/data/TodoList.db
```

The current ECS task definition does not mount persistent storage. Todo records are lost when the task is replaced or recreated.

Keep:

```hcl
ecs_desired_count = 1
```

With multiple ECS tasks, each task would have its own independent SQLite database and users could receive different data depending on which task handles the request.

## Security notes

- AWS access keys are stored only in Jenkins Credentials.
- The EC2 private key must not be committed to Git.
- The ALB currently uses HTTP on port `80`; HTTPS is not configured.
- ECS tasks receive public IPs in the current network design, while inbound application traffic remains restricted to the ALB Security Group.
- A hardened deployment can extend this design with private subnets, HTTPS, stronger IAM separation, persistent storage, and a remote Terraform backend.
