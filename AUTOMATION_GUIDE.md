# 🚀 Complete E-SHOP AWS Deployment Automation Guide

## Overview

E-SHOP has **5 deployment options**, from simplest to most advanced:

1. **One-Command Bash** ← Simplest
2. **CloudFormation** ← AWS Console friendly
3. **Terraform** ← Infrastructure as Code
4. **GitHub Actions** ← Automated CI/CD
5. **Full Pipeline** ← All combined

Choose based on your needs and experience level.

---

## 🎯 Quick Decision Matrix

| Method | Difficulty | Speed | Automation | Use Case |
|--------|-----------|-------|-----------|----------|
| **Bash Script** | ⭐ Easy | 10 min | Manual | Quick testing |
| **CloudFormation** | ⭐⭐ Medium | 15 min | Partial | AWS-native teams |
| **Terraform** | ⭐⭐⭐ Advanced | 20 min | Full | Multi-cloud, teams |
| **GitHub Actions** | ⭐⭐ Medium | Auto | Full | Developers |
| **Full Pipeline** | ⭐⭐⭐ Advanced | Auto | Full | Enterprise |

---

## 📋 OPTION 1: One-Command Bash (SIMPLEST)

**Best for:** Quick deployment, testing, learning

### Prerequisites
- AWS EC2 instance running
- SSH key pair downloaded
- SSH access to instance

### Deploy

```bash
# SSH into EC2 instance
ssh -i your-key.pem ubuntu@your-ec2-ip

# Run single command
curl -fsSL https://raw.githubusercontent.com/shohnazar-abdusalomov/e-shop/master/full-deploy.sh | bash -s "your-domain.com"
```

**What it does:**
- ✅ Installs Node.js, Nginx, PM2, Git
- ✅ Clones repository
- ✅ Builds app
- ✅ Configures Nginx
- ✅ Sets up SSL (Let's Encrypt)
- ✅ Starts application

**Time:** ~10 minutes
**Automation:** 100%

**Verification:**
```bash
pm2 status
curl http://localhost
```

---

## 🏗️ OPTION 2: CloudFormation (AWS NATIVE)

**Best for:** AWS teams, no DevOps experience

### Prerequisites
- AWS account
- EC2 key pair created
- Domain name (optional)

### Deploy via Console (Easiest)

1. **Go to CloudFormation:**
   - https://console.aws.amazon.com/cloudformation/

2. **Create Stack:**
   - Upload: `cloudformation-template.yaml`
   - Stack name: `eshop-stack`

3. **Configure Parameters:**
   - KeyName: Your EC2 key pair
   - DomainName: Your domain (or default)
   - Email: admin@your-domain.com

4. **Review & Create**
   - Check capabilities
   - Click "Create Stack"

5. **Wait for Completion** (10-15 minutes)

### Deploy via CLI

```bash
aws cloudformation create-stack \
  --stack-name eshop-stack \
  --template-body file://cloudformation-template.yaml \
  --parameters \
    ParameterKey=KeyName,ParameterValue=eshop-key \
    ParameterKey=DomainName,ParameterValue=your-domain.com \
    ParameterKey=Email,ParameterValue=admin@your-domain.com \
  --capabilities CAPABILITY_NAMED_IAM
```

### Get Outputs

```bash
aws cloudformation describe-stacks \
  --stack-name eshop-stack \
  --query 'Stacks[0].Outputs'
```

**Time:** ~15 minutes
**See:** `CLOUDFORMATION_GUIDE.md`

---

## 🔧 OPTION 3: Terraform (IaC BEST PRACTICE)

**Best for:** Teams, version control, multi-environment

### Prerequisites
- Terraform installed
- AWS credentials configured
- EC2 key pair

### Install Terraform

```bash
# macOS
brew install terraform

# Linux
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
echo "deb [arch=amd64] https://apt.releases.hashicorp.com focal main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install terraform

# Windows
choco install terraform
```

### Deploy

```bash
cd terraform

# Copy and edit variables
cp terraform.tfvars.example terraform.tfvars
# Edit: key_name, domain_name, email

# Initialize
terraform init

# Plan
terraform plan -out=tfplan

# Apply
terraform apply tfplan
```

### Get Outputs

```bash
terraform output
terraform output instance_public_ip
terraform output ssh_command
```

**Time:** ~20 minutes
**See:** `terraform/README.md`

---

## ⚙️ OPTION 4: GitHub Actions (CI/CD)

**Best for:** Continuous deployment, developers

### Prerequisites
- GitHub repository (already done! ✅)
- AWS EC2 instance running
- GitHub secrets configured

### Setup GitHub Secrets

1. **Go to Repository:**
   - Settings → Secrets and variables → Actions

2. **Add Secrets:**
   ```
   EC2_HOST: your-ec2-ip
   EC2_SSH_KEY: <contents of your private key>
   SLACK_WEBHOOK_URL: (optional)
   ```

3. **Workflow Will:**
   - Run on every push to `master` branch
   - Build application
   - Run tests/linting
   - Deploy to EC2
   - Send notifications

### Workflows Included

**deploy.yml** - Automatic deployment on push
**test.yml** - Build and test on every commit

### Monitor Deployment

1. **GitHub Actions Tab**
   - View workflow runs
   - Check logs
   - See deployment status

2. **View Live Logs**
   ```bash
   ssh -i your-key.pem ubuntu@<ip>
   pm2 logs eshop-app
   ```

**Time:** ~5 minutes (after config)
**Automation:** 100% (on code push)

---

## 🎯 OPTION 5: Full Pipeline (ENTERPRISE)

**Best for:** Large teams, multiple environments

Combines all above:

```
GitHub Repository
    ↓
GitHub Actions (CI/CD)
    ↓
Terraform (IaC)
    ↓
AWS CloudFormation (Optional)
    ↓
EC2 Deployment
    ↓
Monitoring & Alarms
    ↓
S3 Backups
```

### Setup

1. **Terraform Setup**
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   terraform init
   terraform apply
   ```

2. **GitHub Actions Setup**
   - Add secrets (EC2_HOST, EC2_SSH_KEY)
   - Workflows auto-deploy on push

3. **Monitoring**
   - CloudWatch alarms configured
   - S3 backups enabled
   - Auto-renewal SSL

### Features

- ✅ Infrastructure as Code
- ✅ Automated testing
- ✅ Continuous deployment
- ✅ Monitoring and alerts
- ✅ Automatic backups
- ✅ SSL management
- ✅ Scalable architecture

---

## 📊 Comparison

| Feature | Bash | CloudFormation | Terraform | GitHub Actions | Full Pipeline |
|---------|------|---|---|---|---|
| **Setup Time** | 5 min | 10 min | 20 min | 10 min | 30 min |
| **Learning Curve** | None | Low | High | Low | High |
| **Reusability** | Low | Medium | High | High | High |
| **Team Friendly** | No | Yes | Yes | Yes | Yes |
| **Version Control** | No | Manual | Yes | Yes | Yes |
| **Scaling** | Manual | Manual | Automatic | Automatic | Automatic |
| **Monitoring** | Manual | Included | Included | Included | Included |
| **Cost Tracking** | Manual | Included | Included | Included | Included |

---

## 🚀 Quick Start (Choose One)

### Path 1: Just Deploy Now 🔥
```bash
# Fastest: ~10 minutes
ssh -i your-key.pem ubuntu@ec2-ip
curl -fsSL https://raw.githubusercontent.com/shohnazar-abdusalomov/e-shop/master/full-deploy.sh | bash
```

### Path 2: AWS Console 🎯
```bash
# Visit CloudFormation Console
# Upload cloudformation-template.yaml
# Fill in parameters
# Click Create
# Wait 15 minutes
```

### Path 3: Infrastructure as Code 🏗️
```bash
# Professional setup
cd terraform
terraform init
terraform plan
terraform apply
```

### Path 4: Automated CI/CD 🤖
```bash
# In GitHub repository
# Add EC2_HOST and EC2_SSH_KEY secrets
# Push to master branch
# Automatic deployment!
```

---

## 📁 Files Reference

### Deployment Scripts
```
ec2-setup.sh              - Initial setup
deploy.sh                 - Manual deployment
ssl-setup.sh              - SSL certificate
full-deploy.sh            - One-command deployment
install-docker.sh         - Docker setup
```

### Configuration Files
```
nginx.conf                - Web server
ecosystem.config.js       - PM2 config
docker-compose.yml        - Docker compose
Dockerfile                - Container image
.env.production           - Environment vars
```

### Infrastructure as Code
```
cloudformation-template.yaml   - CloudFormation
terraform/main.tf             - Terraform provider
terraform/variables.tf        - Variables
terraform/ec2.tf              - EC2 resources
terraform/outputs.tf          - Outputs
terraform/user-data.sh        - Init script
```

### CI/CD
```
.github/workflows/deploy.yml   - Deploy workflow
.github/workflows/test.yml     - Test workflow
```

### Documentation
```
START_HERE.md                    - Getting started
DEPLOYMENT_GUIDE.md              - Complete guide
QUICK_CHECKLIST.md               - Quick reference
CLOUDFORMATION_GUIDE.md          - CloudFormation
DOCKER_DEPLOYMENT_GUIDE.md       - Docker
EC2_DEPLOY_INSTRUCTIONS.md       - Manual steps
AUTOMATION_GUIDE.md              - This file
```

---

## 🎯 Recommended Paths by Role

### 👤 Solo Developer
**Start with:** Bash Script (full-deploy.sh)
- Simplest setup
- Quick deployment
- Manual updates OK

**Then move to:** GitHub Actions
- Automate future deployments
- CI/CD integration

### 👥 Small Team (2-5 people)
**Start with:** Terraform
- Share infrastructure code
- Version control
- Easy collaboration

**Add:** GitHub Actions
- Automate deployments
- CI/CD pipeline

### 🏢 Enterprise Team (5+ people)
**Start with:** Full Pipeline
- Terraform for IaC
- GitHub Actions for CI/CD
- Multiple environments
- Monitoring & alerts

---

## 🔄 Deployment Workflow Examples

### Scenario 1: First-Time Deployment

```
Week 1: Bash Script Deploy
├─ SSH to EC2 instance
├─ Run one-command deployment
├─ Verify app works
└─ Domain + SSL setup

Week 2: GitHub Actions Setup
├─ Add EC2_HOST secret
├─ Add EC2_SSH_KEY secret
├─ Push code to master
└─ Auto-deployment working
```

### Scenario 2: Professional Setup

```
Day 1: Terraform Infrastructure
├─ Install Terraform
├─ Configure AWS credentials
├─ Edit terraform.tfvars
├─ Run terraform apply
└─ Infrastructure created

Day 2: GitHub Actions Setup
├─ Add secrets
├─ Verify workflows
├─ Push test commit
└─ Auto-deployment works

Day 3: Monitoring & Backups
├─ CloudWatch alarms active
├─ S3 backups enabled
├─ SSL auto-renewal
└─ Production ready
```

---

## 📞 Troubleshooting by Method

### Bash Script Issues
```bash
# View deployment log
ssh -i key.pem ubuntu@ip
cat /var/log/user-data.log
pm2 logs eshop-app
```

### CloudFormation Issues
```bash
# View stack events
aws cloudformation describe-stack-events --stack-name eshop-stack

# View stack status
aws cloudformation describe-stacks --stack-name eshop-stack
```

### Terraform Issues
```bash
# Enable debug logging
TF_LOG=DEBUG terraform apply

# Refresh state
terraform refresh

# Check logs
cat /var/log/user-data.log
```

### GitHub Actions Issues
```bash
# View workflow logs
# In GitHub → Actions tab
# Click failed workflow
# View logs
```

---

## 🔒 Security Recommendations

### All Methods
- ✅ Use SSH key pairs (not passwords)
- ✅ Restrict security group ingress
- ✅ Enable monitoring and alarms
- ✅ Regular backups
- ✅ SSL certificates

### GitHub Actions
- ✅ Rotate EC2_SSH_KEY regularly
- ✅ Use GitHub secrets (not hardcoded)
- ✅ Restrict workflow access
- ✅ Audit workflow logs

### Terraform
- ✅ Use S3 backend with encryption
- ✅ Enable state file locking
- ✅ Version control terraform files
- ✅ Use IAM roles (not access keys)

---

## 💰 Cost Optimization

### Reduce Costs
- ✅ Use t2.micro (free tier)
- ✅ Set monitoring alarms for costs
- ✅ Use S3 lifecycle policies for old backups
- ✅ Stop instance if not needed

### Monitor Costs
```bash
# View CloudFormation stack costs
aws ce get-cost-and-usage

# View EC2 costs
aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,InstanceType,LaunchTime]'
```

---

## 🎓 Learning Resources

### Bash / Manual
- `EC2_DEPLOY_INSTRUCTIONS.md`
- `DEPLOYMENT_GUIDE.md`

### CloudFormation
- `CLOUDFORMATION_GUIDE.md`
- AWS Documentation: https://docs.aws.amazon.com/cloudformation

### Terraform
- `terraform/README.md`
- Terraform Docs: https://www.terraform.io/docs

### GitHub Actions
- `DEPLOYMENT_COMPLETE.md`
- GitHub Docs: https://docs.github.com/en/actions

---

## ✅ Success Checklist

- [ ] AWS account ready
- [ ] EC2 key pair created
- [ ] Deployment method chosen
- [ ] Followed setup instructions
- [ ] Application deployed
- [ ] Website accessible
- [ ] Domain configured (if using)
- [ ] SSL working (if domain)
- [ ] Monitoring enabled
- [ ] Backups configured

---

## 🚀 Next Steps

1. **Choose deployment method** (above)
2. **Follow the specific guide**
3. **Deploy application**
4. **Verify it's working**
5. **Configure monitoring**
6. **Set up backups**
7. **Automate future deployments**

---

## 📞 Support & Help

**Issue?** Check here:
1. `DEPLOYMENT_COMPLETE.md` - General issues
2. `CLOUDFORMATION_GUIDE.md` - CloudFormation
3. `terraform/README.md` - Terraform
4. `EC2_DEPLOY_INSTRUCTIONS.md` - Manual steps

**Not listed?** Check:
- GitHub issues
- AWS documentation
- Stack Overflow

---

**Choose your path and deploy! 🎉**

- **Fastest:** Bash Script
- **Easiest:** CloudFormation
- **Best Practice:** Terraform
- **Automated:** GitHub Actions
- **Professional:** Full Pipeline

All in this repository. Ready to go! 🚀
