output "aws_account_id" {
  description = "AWS account in which the infrastructure was created."
  value       = data.aws_caller_identity.current.account_id
}

output "jenkins_controller_public_ip" {
  description = "Public IP of the Jenkins Controller."
  value       = aws_instance.jenkins_controller.public_ip
}

output "jenkins_controller_private_ip" {
  description = "Private IP used by SonarQube for the Quality Gate webhook."
  value       = aws_instance.jenkins_controller.private_ip
}

output "jenkins_controller_url" {
  description = "Jenkins web interface URL."
  value       = "http://${aws_instance.jenkins_controller.public_ip}:8080"
}

output "jenkins_agent_public_ip" {
  description = "Public IP of the Jenkins Agent."
  value       = aws_instance.jenkins_agent.public_ip
}

output "jenkins_agent_private_ip" {
  description = "Private IP used when adding the Jenkins Agent node to Jenkins."
  value       = aws_instance.jenkins_agent.private_ip
}

output "ansible_controller_public_ip" {
  description = "Public IP of the Ansible Controller."
  value       = aws_instance.ansible_controller.public_ip
}

output "sonarqube_public_ip" {
  description = "Public IP of the SonarQube server."
  value       = aws_instance.sonarqube.public_ip
}

output "sonarqube_private_ip" {
  description = "Private IP used in the Jenkins SonarQube server configuration."
  value       = aws_instance.sonarqube.private_ip
}

output "sonarqube_url" {
  description = "SonarQube web interface URL."
  value       = "http://${aws_instance.sonarqube.public_ip}:9000"
}

output "ecr_repository_url" {
  description = "URL of the ECR repository used by Jenkins."
  value       = aws_ecr_repository.todo.repository_url
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster used by the Jenkins pipeline."
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
