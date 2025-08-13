#!/bin/bash

# AWS Cleanup Script - Remove All CI/CD Pipeline Resources
echo "=========================================="
echo "🧹 CLEANING UP AWS RESOURCES"
echo "=========================================="
echo "This will delete ALL resources created for the project"
echo ""

# Configuration variables
CLUSTER_NAME="webapp-cicd-cluster"
SERVICE_NAME="webapp-cicd-service"
TASK_FAMILY="webapp-cicd-task"
ECR_REPOSITORY="my-webapp"
AWS_REGION="us-east-1"
GITHUB_USER_NAME="github-actions-user"
SECURITY_GROUP_NAME="webapp-cicd-sg"
LOG_GROUP_NAME="/ecs/webapp-cicd-task"
EXECUTION_ROLE_NAME="ecsTaskExecutionRole-webapp-cicd-cluster"

echo "🚨 WARNING: This will delete:"
echo "  - ECS Service: $SERVICE_NAME"
echo "  - ECS Cluster: $CLUSTER_NAME" 
echo "  - ECR Repository: $ECR_REPOSITORY (and all images)"
echo "  - Task Definitions: $TASK_FAMILY"
echo "  - Security Group: $SECURITY_GROUP_NAME"
echo "  - CloudWatch Logs: $LOG_GROUP_NAME"
echo "  - IAM Role: $EXECUTION_ROLE_NAME"
echo "  - IAM User: $GITHUB_USER_NAME"
echo ""

read -p "Are you sure you want to proceed? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "❌ Cleanup cancelled"
    exit 1
fi

echo ""
echo "🔥 Starting cleanup..."

# 1. Scale down and delete ECS service
echo "📉 Scaling down ECS service..."
aws ecs update-service \
    --cluster $CLUSTER_NAME \
    --service $SERVICE_NAME \
    --desired-count 0 \
    --region $AWS_REGION >/dev/null 2>&1

echo "⏳ Waiting for service to scale down..."
aws ecs wait services-stable --cluster $CLUSTER_NAME --services $SERVICE_NAME --region $AWS_REGION 2>/dev/null

echo "🗑️ Deleting ECS service..."
aws ecs delete-service \
    --cluster $CLUSTER_NAME \
    --service $SERVICE_NAME \
    --force \
    --region $AWS_REGION >/dev/null 2>&1

# 2. Delete ECS cluster
echo "🗑️ Deleting ECS cluster..."
aws ecs delete-cluster \
    --cluster $CLUSTER_NAME \
    --region $AWS_REGION >/dev/null 2>&1

# 3. Deregister task definitions
echo "🗑️ Deregistering task definitions..."
TASK_DEFINITIONS=$(aws ecs list-task-definitions --family-prefix $TASK_FAMILY --region $AWS_REGION --query 'taskDefinitionArns' --output text)
for task_def in $TASK_DEFINITIONS; do
    aws ecs deregister-task-definition --task-definition $task_def --region $AWS_REGION >/dev/null 2>&1
done

# 4. Delete ECR repository and all images
echo "🗑️ Deleting ECR repository and all images..."
aws ecr delete-repository \
    --repository-name $ECR_REPOSITORY \
    --force \
    --region $AWS_REGION >/dev/null 2>&1

# 5. Delete CloudWatch log group
echo "🗑️ Deleting CloudWatch log group..."
aws logs delete-log-group \
    --log-group-name $LOG_GROUP_NAME \
    --region $AWS_REGION >/dev/null 2>&1

# 6. Delete security group
echo "🗑️ Deleting security group..."
SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=$SECURITY_GROUP_NAME" --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null)
if [ "$SECURITY_GROUP_ID" != "None" ] && [ "$SECURITY_GROUP_ID" != "" ]; then
    aws ec2 delete-security-group --group-id $SECURITY_GROUP_ID 2>/dev/null
fi

# 7. Delete IAM role and policies
echo "🗑️ Deleting IAM execution role..."
aws iam detach-role-policy --role-name $EXECUTION_ROLE_NAME --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy 2>/dev/null
aws iam detach-role-policy --role-name $EXECUTION_ROLE_NAME --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser 2>/dev/null
aws iam detach-role-policy --role-name $EXECUTION_ROLE_NAME --policy-arn arn:aws:iam::aws:policy/CloudWatchLogsFullAccess 2>/dev/null
aws iam delete-role --role-name $EXECUTION_ROLE_NAME 2>/dev/null

# 8. Delete GitHub Actions IAM user and access keys
echo "🗑️ Deleting GitHub Actions IAM user..."
ACCESS_KEYS=$(aws iam list-access-keys --user-name $GITHUB_USER_NAME --query 'AccessKeyMetadata[*].AccessKeyId' --output text 2>/dev/null)
for key in $ACCESS_KEYS; do
    aws iam delete-access-key --user-name $GITHUB_USER_NAME --access-key-id $key 2>/dev/null
done

aws iam detach-user-policy --user-name $GITHUB_USER_NAME --policy-arn arn:aws:iam::aws:policy/AmazonECS_FullAccess 2>/dev/null
aws iam detach-user-policy --user-name $GITHUB_USER_NAME --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess 2>/dev/null
aws iam delete-user --user-name $GITHUB_USER_NAME 2>/dev/null

echo ""
echo "=========================================="
echo "✅ CLEANUP COMPLETE!"
echo "=========================================="
echo ""
echo "🎯 All AWS resources have been deleted:"
echo "  ✅ ECS Service and Cluster removed"
echo "  ✅ ECR Repository and images deleted"
echo "  ✅ Task definitions deregistered"
echo "  ✅ Security group removed"
echo "  ✅ CloudWatch logs deleted"
echo "  ✅ IAM roles and users cleaned up"
echo ""
echo "💰 No more AWS charges will be incurred!"
echo ""
echo "📋 Don't forget to:"
echo "  - Remove GitHub repository secrets (if desired)"
echo "  - Delete the GitHub repository (if no longer needed)"
echo ""
echo "🎉 Project complete! Great job on your DevOps pipeline!"
echo "=========================================="
