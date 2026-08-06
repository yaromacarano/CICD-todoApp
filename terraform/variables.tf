variable "aws_region" {
  description = "AWS region in which the infrastructure is created."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short name used in AWS resource names and tags."
  type        = string
  default     = "todo-gitlab"
}

variable "environment" {
  description = "Environment name used in resource tags."
  type        = string
  default     = "dev"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair used for SSH access."
  type        = string
  default     = "todo-app-key"
}

variable "admin_cidr" {
  description = "Administrator public IPv4 address in CIDR notation, for example 203.0.113.10/32."
  type        = string

  validation {
    condition     = can(cidrhost(var.admin_cidr, 0)) && !strcontains(var.admin_cidr, ":")
    error_message = "admin_cidr must be a valid IPv4 CIDR block."
  }
}

variable "gitlab_runner_instance_type" {
  description = "EC2 instance type for the self-hosted GitLab Runner."
  type        = string
  default     = "t3.medium"
}

variable "ansible_controller_instance_type" {
  description = "EC2 instance type for the Ansible Controller."
  type        = string
  default     = "t3.micro"
}

variable "ecs_desired_count" {
  description = "Number of application tasks maintained by the ECS service."
  type        = number
  default     = 1

  validation {
    condition     = var.ecs_desired_count >= 1
    error_message = "ecs_desired_count must be at least 1."
  }
}
