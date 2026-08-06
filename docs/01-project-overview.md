# Project Overview

## Purpose

This release adds infrastructure as code and automated Runner configuration to the GitLab CI version of the application.

## Workflow

1. Terraform creates EC2, IAM, ECR, ECS, ALB and CloudWatch resources.
2. Ansible installs Docker and GitLab Runner on EC2.
3. GitLab Runner executes the pipeline with the Docker executor.
4. Maven tests and builds the application.
5. SonarQube Cloud checks the Quality Gate.
6. GitLab CI pushes the image to ECR and updates ECS.
7. ALB exposes the application.

## Responsibilities

| Component | Responsibility |
| --- | --- |
| Terraform | AWS infrastructure and GitLab CI IAM user |
| Ansible Controller | Runner configuration |
| GitLab Runner | Pipeline execution |
| SonarQube Cloud | Static analysis and Quality Gate |
| ECR | Docker image storage |
| ECS Fargate | Application runtime |
| ALB | Public endpoint and health checks |
| CloudWatch Logs | Container logs |

## Security

- GitLab CI uses a dedicated IAM user without Console access.
- Its policy permits only ECR push, ECS deployment and passing the ECS execution role.
- AWS keys and the SonarQube token are stored as masked GitLab variables.
- `terraform.tfstate` is private because it contains the AWS Secret Key.
- SSH is limited by security groups.
- EC2 uses IMDSv2.
- The Runner is assigned only to this project.

Docker-in-Docker requires privileged mode. Do not use this Runner for untrusted projects or untagged jobs.

## First deployment

The initial ECS task may stop because the new ECR repository has no image. The first successful `main` pipeline pushes an image and updates the service.
