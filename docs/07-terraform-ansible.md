# Terraform and Ansible Setup

## 1. Requirements

- Terraform 1.7+
- AWS CLI
- AWS credentials with permissions for EC2, IAM, ECR, ECS, ALB and CloudWatch
- an EC2 key pair in the target region
- SSH and SCP

Verify local access:

```bash
terraform version
aws --version
aws sts get-caller-identity
```

Do not use AWS root credentials.

## 2. Terraform variables

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Set the EC2 key pair and administrator IP:

```hcl
aws_region = "us-east-1"
key_name   = "todo-app-key"
admin_cidr = "203.0.113.10/32"

gitlab_runner_instance_type      = "t3.medium"
ansible_controller_instance_type = "t3.micro"

ecs_desired_count = 1
```

`terraform.tfvars` is ignored by Git.

## 3. Create the infrastructure

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
terraform output
```

Required outputs include:

- `gitlab_runner_private_ip`;
- `ansible_controller_public_ip`;
- ECR and ECS values;
- `application_url`.

Sensitive AWS keys are read separately in step 8.

## 4. Create the GitLab Runner

Open **Settings → CI/CD → Runners → New project runner** and configure:

- tags: `aws`, `docker`, `ec2`;
- **Run untagged jobs**: disabled;
- project assignment: current project only;
- protected status: enabled only when `main` is protected.

Create the Runner and copy the `glrt-` authentication token.

## 5. Copy Ansible to the Controller

Run from the repository root and replace the placeholders:

```bash
scp -i ~/keys/todo-app-key.pem -r ansible \
  ubuntu@<ANSIBLE_CONTROLLER_PUBLIC_IP>:/home/ubuntu/

scp -i ~/keys/todo-app-key.pem ~/keys/todo-app-key.pem \
  ubuntu@<ANSIBLE_CONTROLLER_PUBLIC_IP>:/home/ubuntu/.ssh/todo-app-key.pem

ssh -i ~/keys/todo-app-key.pem \
  ubuntu@<ANSIBLE_CONTROLLER_PUBLIC_IP>
```

On the Controller:

```bash
chmod 400 ~/.ssh/todo-app-key.pem
cloud-init status --wait
ansible --version
```

## 6. Create the inventory

```bash
cd ~/ansible
cp inventory/hosts.ini.example inventory/hosts.ini
nano inventory/hosts.ini
```

Use the Terraform output `gitlab_runner_private_ip`:

```ini
[gitlab_runners]
gitlab-runner ansible_host=172.31.0.10

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/todo-app-key.pem
ansible_python_interpreter=/usr/bin/python3
```

Test the connection:

```bash
ansible all -m ping
```

## 7. Configure the Runner

```bash
read -s -p "GitLab Runner token: " GITLAB_RUNNER_TOKEN
echo
export GITLAB_RUNNER_TOKEN
ansible-playbook playbooks/site.yml
unset GITLAB_RUNNER_TOKEN
```

The playbook installs Docker and GitLab Runner, registers the Docker executor, enables privileged mode and verifies the GitLab connection.

The Runner must show **Online** in GitLab.

## 8. Add GitLab variables

Open **Settings → CI/CD → Variables**.

Read the AWS keys from the local `terraform/` directory:

```bash
terraform output -raw gitlab_aws_access_key_id
terraform output -raw gitlab_aws_secret_access_key
```

Add the AWS variables:

| Key | Value source | Visibility |
| --- | --- | --- |
| `AWS_ACCESS_KEY_ID` | `gitlab_aws_access_key_id` output | Masked |
| `AWS_SECRET_ACCESS_KEY` | `gitlab_aws_secret_access_key` output | Masked |
| `AWS_DEFAULT_REGION` | `terraform.tfvars` | Visible |
| `ECR_REPOSITORY_URL` | `ecr_repository_url` output | Visible |
| `ECS_CLUSTER` | `ecs_cluster_name` output | Visible |
| `ECS_SERVICE` | `ecs_service_name` output | Visible |
| `ECS_TASK_FAMILY` | `ecs_task_family` output | Visible |
| `ECS_TASK_EXECUTION_ROLE_ARN` | `ecs_task_execution_role_arn` output | Visible |
| `ECS_LOG_GROUP` | `ecs_log_group` output | Visible |
| `APPLICATION_URL` | `application_url` output | Visible |

Create a SonarQube Cloud project from the GitLab repository and add:

| Key | Value | Visibility |
| --- | --- | --- |
| `SONAR_ORGANIZATION` | organization key | Visible |
| `SONAR_PROJECT_KEY` | project key | Visible |
| `SONAR_TOKEN` | analysis token | Masked |

Use **Protected** only when `main` is protected.

Never commit or capture AWS keys, tokens, `terraform.tfstate`, `terraform.tfvars` or PEM files in screenshots.

## 9. Run the pipeline

Push the project to `main`. Expected order:

```text
test-job
build-job
sonarqube-check-job
push-image-job
deploy-ecs-job
```

After deployment, open `APPLICATION_URL`.

## 10. Verify

- Runner is online.
- All five jobs are successful.
- SonarQube Quality Gate passed.
- ECR contains the numbered image.
- ECS uses a new task definition revision.
- ECS service has a running task.
- The application opens through ALB.

## 11. Rotate AWS keys

```bash
cd terraform
terraform apply -replace=aws_iam_access_key.gitlab_ci
```

Replace both AWS variables in GitLab immediately after rotation.

## 12. Destroy the environment

```bash
cd terraform
terraform plan -destroy
terraform destroy
```

After destruction, remove the AWS variables and the Project Runner from GitLab.
