# Documentation Screenshots

This folder contains screenshots documenting the CI/CD pipeline setup and deployment process.

## Required Screenshots

### 1. Local Development (`01-local-development/`)
- `app-running-locally.png` - Browser showing app running on localhost:3001
- `health-check-endpoint.png` - Browser showing /health endpoint response
- `api-info-endpoint.png` - Browser showing /api/info endpoint response
- `terminal-npm-start.png` - Terminal showing successful npm start

### 2. Docker Testing (`02-docker-testing/`)
- `docker-build-success.png` - Terminal showing successful docker build
- `docker-run-command.png` - Terminal showing docker run command
- `docker-app-running.png` - Browser showing dockerized app running

### 3. AWS Setup (`03-aws-setup/`)
- `aws-configure-output.png` - Terminal showing aws configure and caller identity
- `aws-setup-script-output.png` - Terminal showing aws_setup.sh execution and outputs
- `aws-console-ecr-repo.png` - AWS Console showing created ECR repository
- `aws-console-ecs-cluster.png` - AWS Console showing created ECS cluster
- `aws-console-ecs-service.png` - AWS Console showing created ECS service

### 4. GitHub Setup (`04-github-setup/`)
- `github-repo-created.png` - GitHub showing the new repository
- `github-secrets-configured.png` - GitHub Settings > Secrets showing all required secrets
- `github-actions-workflow-file.png` - GitHub showing the workflow file in .github/workflows/

### 5. CI/CD Pipeline (`05-cicd-pipeline/`)
- `github-actions-triggered.png` - GitHub Actions tab showing workflow triggered by push
- `github-actions-test-stage.png` - GitHub Actions showing test stage running/completed
- `github-actions-build-push.png` - GitHub Actions showing build and push to ECR
- `github-actions-deploy-stage.png` - GitHub Actions showing deploy to ECS
- `github-actions-success.png` - GitHub Actions showing successful deployment with live URL

### 6. Live Application (`06-live-application/`)
- `live-app-homepage.png` - Browser showing live app at public IP
- `live-app-health.png` - Browser showing live health endpoint
- `live-app-api.png` - Browser showing live API endpoint
- `aws-ecs-service-running.png` - AWS Console showing ECS service with running tasks

### 7. Automated Updates (`07-automated-updates/`)
- `code-change-commit.png` - Terminal/IDE showing code change and git commit
- `github-actions-redeployment.png` - GitHub Actions showing automatic redeployment
- `updated-app-live.png` - Browser showing updated app reflecting the changes

### 8. Monitoring & Logs (`08-monitoring/`)
- `cloudwatch-logs.png` - AWS CloudWatch showing application logs
- `ecs-service-events.png` - AWS ECS showing service events and health

## File Naming Convention
- Use descriptive names with dashes
- Include step numbers for chronological order
- Use PNG format for best quality
- Keep file sizes reasonable (under 2MB each)

## Tips for Screenshots
- Use full browser window captures when showing web interfaces
- Include terminal prompts and commands for context
- Highlight important sections with red boxes or arrows if needed
- Ensure text is readable at reasonable zoom levels
- Capture success messages and important outputs clearly
