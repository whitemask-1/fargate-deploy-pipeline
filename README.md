# Project 2: Automated Deployment Pipeline (AWS)

A complete CI/CD pipeline that automatically tests and deploys a Node.js app to AWS ECS using GitHub Actions, Docker, and AWS Fargate.

> **Portfolio Note**: This project demonstrates my ability to create production-ready CI/CD pipelines using modern DevOps practices and AWS cloud services.

> **🎉 DEPLOYMENT STATUS: SUCCESS!** - Fully operational CI/CD pipeline with live production application.

---

## 🌐 What This Project Delivers

* Node.js web application with health checks
* Automated testing on every code push
* Docker containerization
* AWS ECR for container storage
* AWS ECS Fargate for hosting
* Complete CI/CD pipeline with GitHub Actions
* Live production URL

---

## 🛠️ Prerequisites

* [Node.js](https://nodejs.org/) v18+
* [Docker Desktop](https://www.docker.com/products/docker-desktop)
* [AWS CLI](https://aws.amazon.com/cli/) v2
* [Git](https://git-scm.com/)
* GitHub account
* AWS account (free tier works!)

---

## 📅 Step-by-Step Setup

### ✅ Step 1: Test Locally First

```bash
npm install
npm start
```

* Open: [http://localhost:3001](http://localhost:3001)
* Health check: [http://localhost:3001/health](http://localhost:3001/health)
* API endpoint: [http://localhost:3001/api/info](http://localhost:3001/api/info)

---

### ✅ Step 2: Test Docker Build

```bash
docker build -t my-webapp .
docker run -p 3001:3001 -e ENVIRONMENT=local my-webapp
```

* Visit: [http://localhost:3001](http://localhost:3001)

---

### ✅ Step 3: Set Up AWS Infrastructure

```bash
aws configure
aws sts get-caller-identity
chmod +x aws_setup.sh
./aws_setup.sh
```

* Save all outputs to use in GitHub secrets

---

### ✅ Step 4: Add GitHub Repository Secrets

Go to:

* Settings → Secrets and variables → Actions

Add these secrets:

| Secret Name              | Value from Script   | Description                |
| ------------------------ | ------------------- | -------------------------- |
| AWS\_ACCESS\_KEY\_ID     | output              | GitHub Actions AWS access  |
| AWS\_SECRET\_ACCESS\_KEY | output              | GitHub Actions AWS secret  |
| AWS\_REGION              | us-east-1           | AWS region                 |
| ECR\_REPOSITORY          | my-webapp           | Container registry name    |
| ECS\_CLUSTER             | webapp-cicd-cluster | ECS cluster name           |
| ECS\_SERVICE             | webapp-cicd-service | ECS service name           |
| ECS\_TASK\_DEFINITION    | webapp-cicd-task    | ECS task definition family |

---

### ✅ Step 5: Deploy via GitHub

```bash
git add .
git commit -m "Initial commit: AWS DevOps webapp with CI/CD"
git branch -M main
git remote add origin https://github.com/YOURUSERNAME/YOURREPO.git
git push -u origin main
```

---

### ✅ Step 6: Watch the Magic Happen!

* Go to GitHub repo → **Actions tab**
* Observe:

  * Test Stage: Runs tests and Docker build
  * Build & Push: Sends image to ECR
  * Deploy: Updates ECS service

Look for:

```
🚀 Your app is live at: http://[IP]:3001
```

---

### ✅ Step 7: Test My Live Application

* App: http\://\[IP]:3001
* Health: http\://\[IP]:3001/health
* API: http\://\[IP]:3001/api/info

---

### ✅ Step 8: Making Changes

```bash
git add app.js
git commit -m "Updated welcome message"
git push
```

* GitHub Actions redeploys automatically
* Update live in \~3-5 mins

---

## 📊 How It Works

### Pipeline Flow

1. Code Push → GitHub Actions Trigger
2. Test Stage → Run tests and Docker build
3. Build & Push → Image pushed to ECR
4. Deploy → ECS service updated
5. App goes live!

### AWS Components

* **ECR**: Docker image registry
* **ECS Fargate**: Serverless container hosting
* **CloudWatch**: Logs and metrics
* **IAM**: Secure permission control
* **VPC/Security Groups**: Network access

---

## 🔧 Troubleshooting

### Local Issues

* **npm install fails**:

```bash
npm cache clean --force
rm -rf node_modules package-lock.json
npm install
```

* **Port 3001 in use**:

```bash
lsof -ti :3001 | xargs kill -9
PORT=3002 npm start
```

### AWS Issues

* **AWS CLI not configured**:

```bash
aws configure
aws sts get-caller-identity
```

* **Permission denied**:

  * Use `AdministratorAccess` policy (for testing only)

* **Script fails**:

```bash
aws --version
bash -x aws_setup.sh
```

### GitHub Actions Issues

* **Workflow not running**:

  * Confirm file exists: `.github/workflows/deploy-aws.yml`
  * Secrets are case-sensitive

* **Authentication failed**:

  * Recheck secrets and names

* **ECR push failed**:

  * Ensure repo exists in ECR

### Deployment Issues

* **ECS not updating**:

  * Check ECS service events and logs

* **Can't access app**:

  * Wait a few mins
  * Check security group port 3001

* **Container restarting**:

  * Use `CloudWatch` logs to debug
  * Common issue: App not listening on correct port

---

## 📈 Advanced Features

### Environment Variables

```javascript
const dbUrl = process.env.DATABASE_URL || 'localhost';
const apiKey = process.env.API_KEY || 'dev-key';
```

### Multiple Environments

```bash
CLUSTER_NAME="webapp-staging-cluster"
./aws-setup.sh
```

### Monitoring & Alerts

* Use CloudWatch Logs
* Add alarms for CPU/memory thresholds

---

## 🧹 Clean Up Resources

```bash
aws ecs update-service --cluster webapp-cicd-cluster --service webapp-cicd-service --desired-count 0
aws ecs delete-service --cluster webapp-cicd-cluster --service webapp-cicd-service --force
aws ecs delete-cluster --cluster webapp-cicd-cluster
aws ecr delete-repository --repository-name my-webapp --force
aws logs delete-log-group --log-group-name /ecs/webapp-cicd-task
```

(Optional: delete IAM user and keys if created)

---

## 🌟 What I Learned

* ✅ Node.js app deployment best practices
* ✅ Docker containerization
* ✅ GitHub Actions CI/CD pipelines
* ✅ AWS ECS Fargate + ECR usage
* ✅ IAM security roles
* ✅ Infrastructure automation
* ✅ CloudWatch monitoring

---

## 🎯 Deployment Success Summary

**✅ Successfully Deployed:** Full-stack CI/CD pipeline operational

**🔧 Issues Resolved During Setup:**
- Container name mismatch between task definition and GitHub Actions workflow
- ECR permissions missing for ECS task execution role  
- CloudWatch Logs permissions missing for ECS task execution role
- CloudWatch log group missing for application logging

**🚀 Final Result:** 
- Live Node.js application running on AWS ECS Fargate
- Automated deployments via GitHub Actions
- Complete monitoring and logging with CloudWatch
- Production-ready infrastructure with proper IAM security

**📊 Key Metrics:**
- Deployment time: ~3-5 minutes after permission fixes
- Pipeline stages: Test → Build → Deploy → Live
- Infrastructure: ECR + ECS + Fargate + CloudWatch + GitHub Actions

---

## 🚀 Next Steps

* Add tests
* Try blue-green deployments
* Connect a database
* Create staging/prod separation
* Move to **Project 3: Kubernetes Orchestration**

🎉 **Congratulations! I built a full AWS DevOps pipeline!**
# CloudWatch log group created
