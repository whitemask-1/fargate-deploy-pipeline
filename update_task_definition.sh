#!/bin/bash

# Update task definition with correct container name
echo "Updating task definition with correct container name..."

# Get the execution role ARN
EXECUTION_ROLE_ARN=$(aws iam get-role --role-name ecsTaskExecutionRole-webapp-cicd-cluster --query 'Role.Arn' --output text)

# Register new task definition with correct container name
aws ecs register-task-definition \
    --family webapp-cicd-task \
    --network-mode awsvpc \
    --requires-compatibilities FARGATE \
    --cpu 256 \
    --memory 512 \
    --execution-role-arn $EXECUTION_ROLE_ARN \
    --container-definitions '[
        {
            "name": "webapp-container",
            "image": "nginx:latest",
            "portMappings": [
                {
                    "containerPort": 80,
                    "protocol": "tcp"
                }
            ],
            "environment": [
                {
                    "name": "ENVIRONMENT",
                    "value": "production"
                }
            ],
            "essential": true,
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "/ecs/webapp-cicd-task",
                    "awslogs-region": "us-east-1",
                    "awslogs-stream-prefix": "ecs"
                }
            }
        }
    ]' \
    --region us-east-1

echo "✅ Task definition updated with container name: webapp-container"
