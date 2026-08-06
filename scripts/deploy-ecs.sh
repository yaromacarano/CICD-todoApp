#!/usr/bin/env bash
set -euo pipefail

required_variables=(
  IMAGE_URI
  AWS_DEFAULT_REGION
  ECS_CLUSTER
  ECS_SERVICE
  ECS_TASK_FAMILY
  ECS_TASK_EXECUTION_ROLE_ARN
  ECS_LOG_GROUP
)

for variable_name in "${required_variables[@]}"; do
  if [[ -z "${!variable_name:-}" ]]; then
    echo "Required variable is missing: ${variable_name}" >&2
    exit 1
  fi
done

echo "Preparing the ECS task definition..."

sed \
  -e "s|IMAGE_URI_PLACEHOLDER|${IMAGE_URI}|g" \
  -e "s|AWS_REGION_PLACEHOLDER|${AWS_DEFAULT_REGION}|g" \
  -e "s|TASK_FAMILY_PLACEHOLDER|${ECS_TASK_FAMILY}|g" \
  -e "s|TASK_EXECUTION_ROLE_ARN_PLACEHOLDER|${ECS_TASK_EXECUTION_ROLE_ARN}|g" \
  -e "s|LOG_GROUP_PLACEHOLDER|${ECS_LOG_GROUP}|g" \
  aws/task-definition-template.json > aws/task-definition.json

echo "Registering a new ECS task definition revision..."

task_definition_arn="$(
  aws ecs register-task-definition \
    --cli-input-json file://aws/task-definition.json \
    --query 'taskDefinition.taskDefinitionArn' \
    --output text
)"

echo "Updating the ECS service..."

aws ecs update-service \
  --cluster "$ECS_CLUSTER" \
  --service "$ECS_SERVICE" \
  --task-definition "$task_definition_arn" \
  --query 'service.serviceName' \
  --output text

echo "Waiting until the ECS service is stable..."

aws ecs wait services-stable \
  --cluster "$ECS_CLUSTER" \
  --services "$ECS_SERVICE"

echo "Deployment completed successfully."

