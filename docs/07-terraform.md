# Terraform Infrastructure

## Purpose

Terraform creates the AWS infrastructure used by the GitHub Actions deployment. It is run manually from a local workstation and is intentionally separate from `.github/workflows/deploy.yml`.

This separation keeps two different types of change independent:

- Terraform changes the AWS environment;
- GitHub Actions changes the application version running in that environment.

Ansible is not required in this branch because GitHub-hosted runners are created and prepared by the workflow for every run. SonarQube Cloud is also managed externally, so there is no SonarQube EC2 server to configure.

## Prerequisites

- Terraform `1.7` or newer, below `2.0`
- AWS CLI
- an AWS account
- AWS credentials configured on the local machine
- permission to create ECR, ECS, EC2 networking, Elastic Load Balancing, IAM, and CloudWatch resources
- a default VPC with subnets in at least two Availability Zones

Check the local tools:

```bash
terraform version
aws sts get-caller-identity
```

The second command confirms which AWS account Terraform will use.

## Terraform files

| File | Responsibility |
| --- | --- |
| `versions.tf` | Terraform and AWS provider versions |
| `providers.tf` | AWS region and common resource tags |
| `variables.tf` | Input variables and defaults |
| `terraform.tfvars.example` | Example values for local configuration |
| `data.tf` | Current AWS account, default VPC, and default subnets |
| `security-groups.tf` | ALB and ECS traffic rules |
| `alb.tf` | Load balancer, target group, listener, and health check |
| `ecr.tf` | ECR repository for application images |
| `iam.tf` | ECS task execution role and managed policy attachment |
| `ecs.tf` | CloudWatch log group, cluster, task definition, and Fargate service |
| `outputs.tf` | Resource names, role ARN, repository URL, and application URL |

## Resources created

Terraform creates:

- ECR repository `todo-app`;
- ECS cluster `newcluster`;
- ECS service `todo-ecs-service` with one Fargate task by default;
- initial task definition family `todo-task`;
- CloudWatch log group `/ecs/todo-task`;
- Application Load Balancer `todo-ELB`;
- target group `todo-target-group` and HTTP listener on port `80`;
- load balancer security group with public HTTP access;
- ECS security group accepting port `8080` only from the load balancer;
- IAM role `ecsTaskExecutionRole` with `AmazonECSTaskExecutionRolePolicy`.

The default VPC and its subnets are read as existing data. Terraform does not create a new VPC.

## Variable file

Create the local variable file from the example:

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Current example:

```hcl
aws_region       = "us-east-1"
ecs_desired_count = 1
```

`terraform.tfvars` is excluded from Git and should remain local.

## Create or update the infrastructure

Run the commands from the `terraform/` directory:

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

Review the plan before approving `terraform apply`. Terraform then creates or updates only the resources shown in the plan.

`terraform init` is safe to run again after cloning the repository or changing provider or backend configuration.

## Outputs

After `terraform apply`, show the outputs with:

```bash
terraform output
```

The configuration returns:

| Output | Use |
| --- | --- |
| `aws_account_id` | Confirms the target AWS account |
| `ecr_repository_url` | Complete ECR repository address |
| `ecs_cluster_name` | Value for GitHub Variable `CLUSTER` |
| `ecs_service_name` | Value for GitHub Variable `SERVICE` |
| `ecs_task_execution_role_arn` | Role used by the ECS task definition |
| `application_url` | Public ALB address |

The application URL becomes healthy only after a working image has been deployed.

## Connect Terraform resources to GitHub Actions

Create these GitHub Variables:

| GitHub Variable | Value from the current Terraform configuration |
| --- | --- |
| `AWS_REGION` | `us-east-1` |
| `ECR_REPOSITORY` | `todo-app` |
| `CONTAINER_NAME` | `todo` |
| `SERVICE` | `todo-ecs-service` |
| `CLUSTER` | `newcluster` |

Terraform does not create the AWS credentials used by GitHub Actions. Add the AWS access key and secret key separately as GitHub Secrets.

SonarQube Cloud also requires:

- secret `SONAR_TOKEN`;
- variable `SONAR_ORGANIZATION`;
- variable `SONAR_PROJECT_KEY`.

## First deployment sequence

Terraform and GitHub Actions do not start each other automatically. Use this order for a new environment:

1. Run `terraform apply` locally.
2. Add the required GitHub Secrets and Variables.
3. Open **GitHub → Actions → Todo CI/CD WF**.
4. Select **Run workflow**.
5. Select the `github-actions` branch and start the run.
6. Wait for both jobs to succeed.
7. Open the `application_url` returned by Terraform.

The initial ECS task definition references `todo-app:latest`. If the new ECR repository is empty, ECS can show a stopped task before step 5. The first workflow run pushes a real image and updates the service to a new task definition revision.

## Later application deployments

Once the infrastructure exists, Terraform is not needed for ordinary application updates.

```text
Push to github-actions → workflow → new ECR image → new ECS revision
```

Run Terraform again only when the infrastructure configuration changes or when you want to review whether the AWS environment still matches the code.

## Why Terraform ignores the deployed task revision

GitHub Actions registers a new ECS task definition revision after every deployment. The ECS service resource therefore contains:

```hcl
lifecycle {
  ignore_changes = [task_definition]
}
```

This prevents a later `terraform apply` from moving the service back to the original revision. Terraform manages the service configuration; GitHub Actions manages which application revision the service runs.

## Terraform state

This project currently uses local state. Terraform stores the relationship between the configuration and the AWS resources in:

```text
terraform.tfstate
```

The file is excluded from Git because it may contain infrastructure details. Keep it safely on the machine used to manage this environment.

If the state is deleted, Terraform can no longer recognise the existing resources and may propose creating them again. Do not run `terraform apply` with a new empty state against the same environment.

A remote backend such as S3 can be added in a later version when the project needs shared or automated Terraform execution.

## Review current infrastructure

Before changing anything, run:

```bash
terraform plan
```

If the plan shows no changes, the Terraform-managed infrastructure matches the configuration. A new ECS task definition created by GitHub Actions should not cause Terraform to roll back the service because `task_definition` is ignored.

## Destroy the environment

AWS charges continue while the ALB and Fargate task exist. When the environment is no longer needed:

1. Open Amazon ECR in the AWS Console.
2. Delete the images from repository `todo-app`.
3. Run:

```bash
cd terraform
terraform plan -destroy
terraform destroy
```

ECR images must be removed first because the repository uses `force_delete = false`.

Review the destroy plan before confirming. Terraform removes only the resources tracked in the current state; it does not delete the default VPC or its existing subnets.

## Known limitations

- State is local rather than stored in a remote backend.
- Resource names are fixed and may conflict with older resources in the same AWS account.
- The first ECS task can fail before the first image is published.
- The configuration uses the default VPC and public task IPs to stay simple.
- GitHub Actions uses long-lived AWS access keys rather than OIDC.
- SQLite data is not persistent when ECS replaces the task.

These limitations are acceptable for the current small environment, but they should be revisited before using the design for a production workload.

## References

- [Terraform init](https://developer.hashicorp.com/terraform/cli/commands/init)
- [Terraform plan](https://developer.hashicorp.com/terraform/cli/commands/plan)
- [Terraform apply](https://developer.hashicorp.com/terraform/cli/commands/apply)
- [Terraform state](https://developer.hashicorp.com/terraform/language/state)
