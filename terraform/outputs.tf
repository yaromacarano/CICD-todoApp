output "aws_account_id" {
  description = "AWS account in which the infrastructure was created."
  value       = data.aws_caller_identity.current.account_id
}

output "ecr_repository_url" {
  description = "URL of the ECR repository."
  value       = aws_ecr_repository.todo.repository_url
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  value       = aws_ecs_cluster.todo.name
}

output "ecs_service_name" {
  description = "Name of the ECS service used by the Jenkins pipeline."
  value       = aws_ecs_service.todo.name
}

output "ecs_task_execution_role_arn" {
  description = "Role ARN that must match aws/task-definition-template.json."
  value       = aws_iam_role.ecs_task_execution.arn
}

output "application_url" {
  description = "Public URL of the Todo application. It becomes healthy after the first image is deployed."
  value       = "http://${aws_lb.todo.dns_name}"
}
