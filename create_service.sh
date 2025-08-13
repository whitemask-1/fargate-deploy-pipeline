#!/bin/bash

# Recreate the missing ECS service
echo "🚀 Creating missing ECS service..."

# Configuration
CLUSTER_NAME="webapp-cicd-cluster"
SERVICE_NAME="webapp-cicd-service"
TASK_FAMILY="webapp-cicd-task"
AWS_REGION="us-east-1"

# Get VPC and networking info
DEFAULT_VPC=$(aws ec2 describe-vpcs --filters "Name=is-default,Values=true" --query 'Vpcs[0].VpcId' --output text)
SUBNETS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$DEFAULT_VPC" --query 'Subnets[*].SubnetId' --output text | tr '\t' ',')
SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=webapp-cicd-sg" --query 'SecurityGroups[0].GroupId' --output text)

echo "Cluster: $CLUSTER_NAME"
echo "Service: $SERVICE_NAME"
echo "Task Definition: $TASK_FAMILY"
echo "Subnets: $SUBNETS"
echo "Security Group: $SECURITY_GROUP_ID"

# Create the service
aws ecs create-service \
    --cluster $CLUSTER_NAME \
    --service-name $SERVICE_NAME \
    --task-definition $TASK_FAMILY \
    --desired-count 1 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[$SUBNETS],securityGroups=[$SECURITY_GROUP_ID],assignPublicIp=ENABLED}" \
    --region $AWS_REGION

if [ $? -eq 0 ]; then
    echo "✅ ECS service created successfully"
    echo "⏳ Waiting for service to stabilize..."
    aws ecs wait services-stable --cluster $CLUSTER_NAME --services $SERVICE_NAME --region $AWS_REGION
    echo "✅ Service is stable and ready"
else
    echo "❌ Failed to create service"
    exit 1
fi
