#!/usr/bin/env bash
set -euo pipefail

echo "Preparing ECS task definition from template..."
sed "s|IMAGE_URI_PLACEHOLDER|$IMAGE_URI|g" aws/task-definition-template.json > aws/task-definition.json

echo "Registering new task definition revision..."
aws ecs register-task-definition \
  --cli-input-json file://aws/task-definition.json

echo "Updating ECS service to use latest revision of family $ECS_TASK_FAMILY..."
aws ecs update-service \
  --cluster "$ECS_CLUSTER" \
  --service "$ECS_SERVICE" \
  --task-definition "$ECS_TASK_FAMILY"

echo "Deployment completed successfully."