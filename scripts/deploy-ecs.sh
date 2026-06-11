#!/bin/bash
set -euo pipefail

echo "Preparing ECS task definition..."
sed "s|IMAGE_URI_PLACEHOLDER|${IMAGE_URI}|g" aws/task-definition-template.json > task-definition.json

echo "Registering new ECS task definition..."
NEW_TASK_DEF_ARN=$(aws ecs register-task-definition \
  --cli-input-json file://task-definition.json \
  --query 'taskDefinition.taskDefinitionArn' \
  --output text)

echo "Updating ECS service..."
aws ecs update-service \
  --cluster "${ECS_CLUSTER}" \
  --service "${ECS_SERVICE}" \
  --task-definition "${NEW_TASK_DEF_ARN}"

echo "Waiting for ECS service to become stable..."
aws ecs wait services-stable \
  --cluster "${ECS_CLUSTER}" \
  --services "${ECS_SERVICE}"

echo "Deployed image: ${IMAGE_URI}"
echo "Task definition: ${NEW_TASK_DEF_ARN}"
