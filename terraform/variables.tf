variable "aws_region" {
  description = "AWS region in which the infrastructure is created."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used in resource tags."
  type        = string
  default     = "todo-app"
}

variable "environment" {
  description = "Environment name used in resource tags."
  type        = string
  default     = "dev"
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
