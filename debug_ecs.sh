#!/bin/bash

# Debug script for ECS service creation issues
CLUSTER_NAME="webapp-cicd-cluster"
SERVICE_NAME="webapp-cicd-service"
TASK_FAMILY="webapp-cicd-task"
AWS_REGION="us-east-1"

echo "=========================================="
echo "ECS Debug Information"
echo "=========================================="

echo "1. Checking AWS CLI configuration..."
aws sts get-caller-identity || { echo "❌ AWS CLI not configured"; exit 1; }

echo ""
echo "2. Checking if cluster exists..."
CLUSTER_INFO=$(aws ecs describe-clusters --clusters $CLUSTER_NAME --region $AWS_REGION --query 'clusters[0]' 2>/dev/null)
if [ "$CLUSTER_INFO" = "null" ] || [ -z "$CLUSTER_INFO" ]; then
    echo "❌ Cluster $CLUSTER_NAME not found"
    echo "Available clusters:"
    aws ecs list-clusters --region $AWS_REGION --query 'clusterArns[*]' --output table
    exit 1
else
    echo "✅ Cluster found: $CLUSTER_NAME"
    echo "$CLUSTER_INFO" | jq .
fi

echo ""
echo "3. Checking services in cluster..."
aws ecs list-services --cluster $CLUSTER_NAME --region $AWS_REGION --query 'serviceArns[*]' --output table

echo ""
echo "4. Checking task definitions..."
aws ecs list-task-definitions --family-prefix $TASK_FAMILY --region $AWS_REGION --query 'taskDefinitionArns[*]' --output table

echo ""
echo "5. Checking if task definition exists..."
TASK_DEF=$(aws ecs describe-task-definition --task-definition $TASK_FAMILY --region $AWS_REGION --query 'taskDefinition' 2>/dev/null)
if [ "$TASK_DEF" = "null" ] || [ -z "$TASK_DEF" ]; then
    echo "❌ Task definition $TASK_FAMILY not found"
else
    echo "✅ Task definition found: $TASK_FAMILY"
fi

echo ""
echo "6. Checking VPC and subnets..."
DEFAULT_VPC=$(aws ec2 describe-vpcs --filters "Name=is-default,Values=true" --query 'Vpcs[0].VpcId' --output text)
echo "Default VPC: $DEFAULT_VPC"

SUBNETS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$DEFAULT_VPC" --query 'Subnets[*].SubnetId' --output text)
echo "Available subnets: $SUBNETS"

echo ""
echo "7. Checking security groups..."
aws ec2 describe-security-groups --filters "Name=group-name,Values=webapp-cicd-sg" --query 'SecurityGroups[*].[GroupId,GroupName]' --output table

echo ""
echo "=========================================="
echo "Debug complete"
echo "=========================================="
