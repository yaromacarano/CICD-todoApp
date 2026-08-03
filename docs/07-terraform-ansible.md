# Terraform and Ansible Infrastructure

## Purpose

This version automates the existing project infrastructure without changing the application architecture.

Terraform creates:

- Jenkins Controller EC2 instance;
- Jenkins Agent EC2 instance;
- Ansible Controller EC2 instance;
- SonarQube EC2 instance;
- Security Groups;
- ECR repository `todo-app`;
- ECS cluster `newcluster`;
- ECS task definition family `todo-task`;
- ECS service `todo-ecs-service`;
- Application Load Balancer, target group, and listener;
- ECS Task Execution IAM role;
- CloudWatch log group `/ecs/todo-task`.

Ansible configures:

- Jenkins Controller with Java 21 and Jenkins;
- Jenkins Agent with Java 21, Maven 3.9, Docker, Git, and AWS CLI;
- SonarQube as a systemd service.

The project deliberately continues to use the default VPC, public subnets, a local Terraform state, and manually configured Jenkins secrets. It does not add a custom VPC, S3 backend, RDS, HTTPS, Route 53, or auto scaling.

## Prerequisites

Install locally:

- Terraform 1.7 or newer;
- AWS CLI;
- Git.

Prepare in AWS:

1. Configure AWS CLI access for the account.
2. Create an EC2 key pair in `us-east-1` and download its private `.pem` file.
3. Confirm that the region has a default VPC with at least two default subnets.
4. Find your current public IP and write it as a `/32` CIDR.

If resources with the same names already exist from the manual setup, Terraform cannot create duplicates. For the first learning deployment, remove the old resources or import them into Terraform state before applying this configuration.

## 1. Create the infrastructure

Open the Terraform directory:

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
aws_region = "us-east-1"
key_name   = "todo-app-key"
admin_cidr = "YOUR_PUBLIC_IP/32"
```

Run Terraform:

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

Show the created addresses:

```bash
terraform output
```

The ECR repository is initially empty. The first ECS task can remain stopped until Jenkins builds and pushes the first application image. This is expected.

## 2. Prepare the Ansible Controller

Terraform `user_data` installs Ansible and Git on the Ansible Controller. Wait until cloud-init finishes, then connect to it:

```bash
ssh -i todo-app-key.pem ubuntu@ANSIBLE_CONTROLLER_PUBLIC_IP
cloud-init status --wait
```

Clone the repository on the controller:

```bash
git clone https://github.com/yaromacarano/CICD-todoApp.git
cd CICD-todoApp/ansible
cp inventory/hosts.ini.example inventory/hosts.ini
```

Copy the private EC2 key to `~/.ssh/todo-app-key.pem` on the Ansible Controller and protect it:

```bash
chmod 600 ~/.ssh/todo-app-key.pem
```

Do not commit the private key. The repository ignores `.pem` files and the real `hosts.ini`.

## 3. Fill the Ansible inventory

Replace the example IP addresses in `inventory/hosts.ini` with Terraform outputs:

```ini
[jenkins_controller]
jenkins-controller ansible_host=JENKINS_CONTROLLER_PUBLIC_IP

[jenkins_agents]
jenkins-agent ansible_host=JENKINS_AGENT_PUBLIC_IP

[sonarqube]
sonarqube-server ansible_host=SONARQUBE_PUBLIC_IP

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/todo-app-key.pem
ansible_python_interpreter=/usr/bin/python3
```

Check connectivity and run all playbooks:

```bash
ansible all -m ping
ansible-playbook playbooks/site.yml
```

Individual playbooks can also be run separately:

```bash
ansible-playbook playbooks/setup-jenkins-controller.yml
ansible-playbook playbooks/setup-jenkins-agent.yml
ansible-playbook playbooks/setup-sonarqube.yml
```

## 4. Finish Jenkins setup

Open the URL returned by `terraform output jenkins_controller_url`.

Read the initial Jenkins password:

```bash
ssh -i todo-app-key.pem ubuntu@JENKINS_CONTROLLER_PUBLIC_IP
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Complete the Jenkins setup wizard and install the plugins listed in `docs/04-jenkins-pipeline.md`.

Create a Jenkins SSH agent node with:

- node name: `jenkins-agent`;
- remote root directory: `/home/jenkins/agent`;
- label: `docker-aws-maven`;
- launch method: `Launch agents via SSH`;
- host: the value of `terraform output jenkins_agent_private_ip`;
- SSH username: `jenkins`;
- credential: the private key belonging to the EC2 key pair.

Ansible copies the EC2 public key authorization from the Ubuntu account to the Jenkins account, so the same private key can be stored in Jenkins Credentials.

Configure these Jenkins tools with the exact names used by `Jenkinsfile`:

- JDK: `JDK21`;
- Maven: `MAVEN3.9`;
- SonarQube Scanner: `sonar8.0`.

Configure the SonarQube server as `sonarserver` using:

```text
http://SONARQUBE_PRIVATE_IP:9000
```

Add the SonarQube webhook:

```text
http://JENKINS_CONTROLLER_PRIVATE_IP:8080/sonarqube-webhook/
```

Add the AWS credential in Jenkins with ID `awscreds`. These credentials need the ECR, ECS, task definition, and `iam:PassRole` permissions documented in `docs/05-aws-ecr-ecs.md`.

No access key, private key, token, or password is stored in this repository.

## 5. Check values used by the pipeline

Compare these Terraform outputs with `Jenkinsfile` and `aws/task-definition-template.json`:

```bash
terraform output aws_account_id
terraform output ecr_repository_url
terraform output ecs_cluster_name
terraform output ecs_service_name
terraform output ecs_task_execution_role_arn
```

The current repository uses AWS account `551647579168`. If Terraform is run in another account, update:

- `ECR_REGISTRY` in `Jenkinsfile`;
- `executionRoleArn` in `aws/task-definition-template.json`.

The resource names remain unchanged, so the existing deployment script continues to work.

## 6. Run the application pipeline

Create a Jenkins Pipeline job using this repository and run it. Jenkins will:

1. execute the build on the Jenkins Agent;
2. analyze the code in SonarQube;
3. push the image to ECR;
4. register a new `todo-task` revision;
5. update `todo-ecs-service`;
6. wait for ECS to become stable.

Terraform ignores later changes to the ECS service task definition revision. This prevents a future `terraform apply` from rolling back the revision deployed by Jenkins.

After a successful pipeline, open:

```bash
terraform output -raw application_url
```

## Cleanup

Before destroying the infrastructure, remove images from the ECR repository or change `force_delete` only when you intentionally want Terraform to delete them.

Then run:

```bash
cd terraform
terraform destroy
```
