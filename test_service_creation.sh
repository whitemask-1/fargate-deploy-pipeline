#!/bin/bash

# Simple script to manually test service creation
CLUSTER_NAME="webapp-cicd-cluster"
SERVICE_NAME="webapp-cicd-service"
TASK_FAMILY="webapp-cicd-task"
AWS_REGION="us-east-1"

echo "=========================================="
echo "Manual ECS Service Creation Test"
echo "=========================================="

echo "1. Testing AWS CLI..."
if aws sts get-caller-identity; then
    echo "✅ AWS CLI working"
else
    echo "❌ AWS CLI not configured"
    exit 1
fi

echo ""
echo "2. Checking cluster..."
aws ecs describe-clusters --clusters $CLUSTER_NAME --region $AWS_REGION

echo ""
echo "3. Checking task definition..."
aws ecs describe-task-definition --task-definition $TASK_FAMILY --region $AWS_REGION --query 'taskDefinition.{family:family,revision:revision,status:status}'

echo ""
echo "4. Listing current services..."
aws ecs list-services --cluster $CLUSTER_NAME --region $AWS_REGION

echo ""
echo "5. Getting VPC info..."
DEFAULT_VPC=$(aws ec2 describe-vpcs --filters "Name=is-default,Values=true" --query 'Vpcs[0].VpcId' --output text)
SUBNETS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$DEFAULT_VPC" --query 'Subnets[*].SubnetId' --output text | tr '\t' ' ')
SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=webapp-cicd-sg" --query 'SecurityGroups[0].GroupId' --output text)

echo "VPC: $DEFAULT_VPC"
echo "Subnets: $SUBNETS"
echo "Security Group: $SECURITY_GROUP_ID"

echo ""
echo "6. Attempting to create service..."
SUBNET_LIST=$(echo $SUBNETS | sed 's/ /,/g')

aws ecs create-service \
    --cluster $CLUSTER_NAME \
    --service-name $SERVICE_NAME \
    --task-definition $TASK_FAMILY \
    --desired-count 1 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[$SUBNET_LIST],securityGroups=[$SECURITY_GROUP_ID],assignPublicIp=ENABLED}" \
    --region $AWS_REGION

echo ""
echo "7. Checking service after creation..."
aws ecs describe-services --cluster $CLUSTER_NAME --services $SERVICE_NAME --region $AWS_REGION
