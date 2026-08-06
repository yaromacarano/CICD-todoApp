output "aws_account_id" {
  description = "AWS account in which the infrastructure was created."
  value       = data.aws_caller_identity.current.account_id
}

output "gitlab_runner_public_ip" {
  description = "Public IP used for direct SSH access to the GitLab Runner."
  value       = aws_instance.gitlab_runner.public_ip
}

output "gitlab_runner_private_ip" {
  description = "Private IP used by the Ansible Controller."
  value       = aws_instance.gitlab_runner.private_ip
}

output "ansible_controller_public_ip" {
  description = "Public IP of the Ansible Controller."
  value       = aws_instance.ansible_controller.public_ip
}

output "gitlab_iam_user_name" {
  description = "IAM user used by the GitLab deployment jobs."
  value       = aws_iam_user.gitlab_ci.name
}

output "gitlab_aws_access_key_id" {
  description = "Set this value as AWS_ACCESS_KEY_ID in GitLab CI/CD variables."
  value       = aws_iam_access_key.gitlab_ci.id
  sensitive   = true
}

output "gitlab_aws_secret_access_key" {
  description = "Set this value as AWS_SECRET_ACCESS_KEY in GitLab CI/CD variables."
  value       = aws_iam_access_key.gitlab_ci.secret
  sensitive   = true
}

output "ecr_repository_url" {
  description = "Set this value as ECR_REPOSITORY_URL in GitLab CI/CD variables."
  value       = aws_ecr_repository.todo.repository_url
}

output "ecs_cluster_name" {
  description = "Set this value as ECS_CLUSTER in GitLab CI/CD variables."
  value       = aws_ecs_cluster.todo.name
}

output "ecs_service_name" {
  description = "Set this value as ECS_SERVICE in GitLab CI/CD variables."
  value       = aws_ecs_service.todo.name
}

output "ecs_task_family" {
  description = "Set this value as ECS_TASK_FAMILY in GitLab CI/CD variables."
  value       = aws_ecs_task_definition.todo.family
}

output "ecs_task_execution_role_arn" {
  description = "Set this value as ECS_TASK_EXECUTION_ROLE_ARN in GitLab CI/CD variables."
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_log_group" {
  description = "Set this value as ECS_LOG_GROUP in GitLab CI/CD variables."
  value       = aws_cloudwatch_log_group.todo.name
}

output "application_url" {
  description = "Public URL of the application after the first successful pipeline deployment."
  value       = "http://${aws_lb.todo.dns_name}"
}
