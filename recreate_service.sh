#!/bin/bash

# Recreate missing ECS service
echo "🔧 Recreating missing ECS service..."

# Configuration
CLUSTER_NAME="webapp-cicd-cluster"
SERVICE_NAME="webapp-cicd-service"
TASK_FAMILY="webapp-cicd-task"
AWS_REGION="us-east-1"

# First, check if cluster exists
echo "🔍 Checking cluster..."
CLUSTER_STATUS=$(aws ecs describe-clusters --clusters $CLUSTER_NAME --region $AWS_REGION --query 'clusters[0].status' --output text 2>/dev/null)

if [ "$CLUSTER_STATUS" != "ACTIVE" ]; then
    echo "❌ Cluster not found or not active. Creating cluster..."
    aws ecs create-cluster --cluster-name $CLUSTER_NAME --region $AWS_REGION
    echo "✅ Cluster created"
fi

# Check if task definition exists
echo "🔍 Checking task definition..."
TASK_DEF_STATUS=$(aws ecs describe-task-definition --task-definition $TASK_FAMILY --region $AWS_REGION --query 'taskDefinition.status' --output text 2>/dev/null)

if [ "$TASK_DEF_STATUS" != "ACTIVE" ]; then
    echo "❌ Task definition not found. You need to run aws_setup.sh first"
    exit 1
fi

# Get networking configuration
echo "🌐 Getting network configuration..."
DEFAULT_VPC=$(aws ec2 describe-vpcs --filters "Name=is-default,Values=true" --query 'Vpcs[0].VpcId' --output text)
SUBNETS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$DEFAULT_VPC" --query 'Subnets[*].SubnetId' --output text | tr '\t' ',')

# Get or create security group
SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=webapp-cicd-sg" --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null)

if [ "$SECURITY_GROUP_ID" = "None" ] || [ -z "$SECURITY_GROUP_ID" ]; then
    echo "🛡️ Creating security group..."
    SECURITY_GROUP_ID=$(aws ec2 create-security-group \
        --group-name webapp-cicd-sg \
        --description "Security group for webapp CI/CD" \
        --vpc-id $DEFAULT_VPC \
        --query 'GroupId' \
        --output text)
    
    # Add inbound rules
    aws ec2 authorize-security-group-ingress \
        --group-id $SECURITY_GROUP_ID \
        --protocol tcp \
        --port 80 \
        --cidr 0.0.0.0/0
    
    aws ec2 authorize-security-group-ingress \
        --group-id $SECURITY_GROUP_ID \
        --protocol tcp \
        --port 3001 \
        --cidr 0.0.0.0/0
    
    echo "✅ Security group created: $SECURITY_GROUP_ID"
fi

echo "📋 Configuration:"
echo "  Cluster: $CLUSTER_NAME"
echo "  Service: $SERVICE_NAME" 
echo "  Task Definition: $TASK_FAMILY"
echo "  VPC: $DEFAULT_VPC"
echo "  Subnets: $SUBNETS"
echo "  Security Group: $SECURITY_GROUP_ID"

# Create the service
echo "🚀 Creating ECS service..."
aws ecs create-service \
    --cluster $CLUSTER_NAME \
    --service-name $SERVICE_NAME \
    --task-definition $TASK_FAMILY \
    --desired-count 1 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[$SUBNETS],securityGroups=[$SECURITY_GROUP_ID],assignPublicIp=ENABLED}" \
    --region $AWS_REGION

if [ $? -eq 0 ]; then
    echo "✅ ECS service created successfully!"
    echo "⏳ Waiting for service to stabilize..."
    aws ecs wait services-stable --cluster $CLUSTER_NAME --services $SERVICE_NAME --region $AWS_REGION --cli-read-timeout 300
    echo "✅ Service is stable and ready for deployments"
else
    echo "❌ Failed to create service"
    exit 1
fi
