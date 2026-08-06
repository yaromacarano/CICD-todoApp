# AWS Infrastructure and Deployment

## Resources

Terraform creates:

- GitLab Runner EC2 and Ansible Controller EC2;
- security groups;
- GitLab CI IAM user and access key;
- GitLab deployment policy;
- ECS task execution role;
- ECR repository;
- ECS cluster, task definition and service;
- CloudWatch log group;
- Application Load Balancer, listener and target group.

The default VPC and its subnets are used.

## Networking

The Runner polls GitLab over outbound HTTPS. It does not require an inbound GitLab connection.

SSH to the Runner is allowed from:

- `admin_cidr`;
- the Ansible Controller security group.

No Docker daemon port is exposed.

## IAM

The `<project-name>-gitlab-ci` user has no Console password. Its policy allows:

- ECR authentication and image push;
- ECS task registration and service update;
- `iam:PassRole` for the project ECS execution role.

It cannot manage the Terraform infrastructure. The keys remain valid until they are rotated or deleted.

## Deployment

Image URI:

```text
<account>.dkr.ecr.<region>.amazonaws.com/<repository>:<CI_PIPELINE_IID>
```

The deployment script replaces the placeholders in `aws/task-definition-template.json`, creates `aws/task-definition.json`, registers a new revision and updates the service. The generated JSON file is ignored by Git.

Terraform ignores later changes to the ECS service task definition because GitLab CI owns application revisions.

## Endpoint and cleanup

The ALB listens on port `80` and forwards traffic to port `8080`. The public URL is returned as `application_url`.

```bash
cd terraform
terraform destroy
```

The ECR repository uses `force_delete = true`, so cleanup also removes stored images. Delete the AWS variables from GitLab after destroying the environment.
