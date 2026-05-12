# Terraform E-SHOP Deployment Guide

## Overview

This Terraform configuration automatically deploys the E-SHOP application to AWS EC2 with:
- VPC and networking
- Security groups
- EC2 instance with auto-deployment
- IAM roles and policies
- Elastic IP
- CloudWatch monitoring and alarms
- S3 backup bucket
- SSL certificate (Let's Encrypt)

---

## Prerequisites

### 1. Install Terraform

**macOS (Homebrew):**
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

**Linux (apt):**
```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform
```

**Windows (Chocolatey):**
```bash
choco install terraform
```

**Verify installation:**
```bash
terraform --version
```

### 2. AWS Credentials

Set up AWS credentials in one of these ways:

**Option A: AWS CLI (Recommended)**
```bash
aws configure
# Enter: Access Key ID, Secret Access Key, Region, Output format
```

**Option B: Environment variables**
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

**Option C: ~/.aws/credentials file**
```bash
[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY
```

### 3. EC2 Key Pair

Create or use existing EC2 key pair:

```bash
# Create new key pair
aws ec2 create-key-pair --key-name eshop-key --query 'KeyMaterial' --output text > eshop-key.pem
chmod 400 eshop-key.pem

# Or use existing key pair name
```

### 4. Terraform Variables

Copy and configure:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
aws_region      = "us-east-1"
environment      = "production"
instance_type    = "t2.micro"
key_name         = "eshop-key"              # Your key pair name
domain_name      = "your-domain.com"        # Your domain
email            = "admin@your-domain.com"  # Your email
enable_backup    = true
enable_monitoring = true
```

---

## Quick Start

### Step 1: Initialize Terraform

```bash
cd terraform
terraform init
```

This downloads providers and initializes the working directory.

### Step 2: Review Plan

```bash
terraform plan -out=tfplan
```

Review the resources that will be created.

### Step 3: Apply Configuration

```bash
terraform apply tfplan
```

Terraform will create all resources. This takes ~5-10 minutes.

### Step 4: Get Outputs

After deployment:

```bash
terraform output
```

You'll see:
- Instance public IP
- SSH command
- Application URL
- Backup bucket name

---

## Usage Examples

### View All Outputs

```bash
terraform output -json
```

### Connect to Instance

```bash
ssh -i /path/to/eshop-key.pem ubuntu@<instance-ip>
```

### Destroy Infrastructure

```bash
terraform destroy
```

### Update Configuration

Edit `terraform.tfvars`, then:

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

### Scale Instance

Change instance type in `terraform.tfvars`:

```hcl
instance_type = "t2.small"  # Upgrade from t2.micro
```

Then apply:

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

---

## Configuration Options

### Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | `us-east-1` | AWS region |
| `environment` | `production` | Environment: development, staging, production |
| `instance_type` | `t2.micro` | EC2 instance type |
| `key_name` | - | EC2 key pair name (required) |
| `domain_name` | `your-domain.com` | Application domain |
| `email` | `admin@example.com` | Email for SSL certificates |
| `root_volume_size` | `30` | Root volume size (GB) |
| `enable_monitoring` | `true` | Enable CloudWatch monitoring |
| `enable_backup` | `true` | Enable S3 backup bucket |
| `backup_retention_days` | `90` | Backup retention period |
| `enable_auto_healing` | `true` | Enable auto-healing |

### Output Descriptions

The deployment provides:

```bash
terraform output instance_public_ip          # EC2 public IP
terraform output ssh_command                 # SSH connection command
terraform output application_url             # HTTP URL
terraform output application_url_ssl         # HTTPS URL (if domain)
terraform output security_group_id           # Security group ID
terraform output vpc_id                      # VPC ID
terraform output backup_bucket_name          # S3 bucket name
```

---

## Monitoring

### CloudWatch Alarms

Alarms are created for:
- Instance status check failures
- High CPU usage (>80%)

View alarms:

```bash
aws cloudwatch describe-alarms --query 'MetricAlarms[?contains(AlarmName, `eshop`)]'
```

### View Instance Logs

```bash
# SSH into instance
ssh -i eshop-key.pem ubuntu@<ip>

# View deployment log
cat /var/log/user-data.log

# View PM2 logs
pm2 logs eshop-app

# View Nginx logs
sudo tail -f /var/log/nginx/eshop_access.log
```

### CloudWatch Logs

```bash
aws logs tail /eshop/application --follow
```

---

## Backup and Restore

### S3 Backup Bucket

Backup bucket is created at:

```bash
eshop-backups-<account-id>
```

View bucket:

```bash
aws s3 ls s3://eshop-backups-<account-id>/
```

### Manual Backup

SSH into instance:

```bash
ssh -i eshop-key.pem ubuntu@<ip>

# Create backup
tar -czf eshop-backup.tar.gz /var/www/eshop

# Upload to S3
aws s3 cp eshop-backup.tar.gz s3://eshop-backups-<account-id>/backups/
```

### Restore from Backup

```bash
# Download backup
aws s3 cp s3://eshop-backups-<account-id>/backups/eshop-backup.tar.gz .

# Extract
tar -xzf eshop-backup.tar.gz

# Restore application
sudo cp -r var/www/eshop/* /var/www/eshop/

# Restart application
pm2 restart eshop-app
```

---

## SSL Certificate

### Automatic Setup

If `domain_name` is not `your-domain.com`, Let's Encrypt certificate is automatically requested during deployment.

### Manual SSL Setup

SSH into instance:

```bash
sudo certbot certonly --nginx \
  -d your-domain.com \
  -d www.your-domain.com \
  --non-interactive \
  --agree-tos \
  -m admin@your-domain.com

sudo systemctl reload nginx
```

### Renew Certificate

```bash
sudo certbot renew
```

---

## Troubleshooting

### Deployment Fails

1. Check AWS credentials:
   ```bash
   aws sts get-caller-identity
   ```

2. Check Terraform logs:
   ```bash
   TF_LOG=DEBUG terraform apply tfplan
   ```

3. Check EC2 user data log:
   ```bash
   ssh -i eshop-key.pem ubuntu@<ip>
   cat /var/log/user-data.log
   ```

### Terraform State Issues

If state is corrupted:

```bash
# Backup current state
cp terraform.tfstate terraform.tfstate.backup

# Refresh state
terraform refresh

# Or reimport resources
terraform import aws_instance.eshop <instance-id>
```

### Application Won't Start

1. Check PM2 status:
   ```bash
   ssh -i eshop-key.pem ubuntu@<ip>
   pm2 status
   pm2 logs eshop-app
   ```

2. Check Nginx:
   ```bash
   sudo systemctl status nginx
   sudo tail -f /var/log/nginx/eshop_error.log
   ```

3. Restart application:
   ```bash
   pm2 restart eshop-app
   sudo systemctl restart nginx
   ```

---

## Best Practices

### 1. Use Remote State (Production)

Enable S3 backend for team collaboration:

```bash
# Uncomment backend in main.tf
# Create S3 bucket and DynamoDB table first
```

### 2. Use Workspaces for Multiple Environments

```bash
# Create workspace
terraform workspace new staging

# List workspaces
terraform workspace list

# Select workspace
terraform workspace select staging

# Deploy to workspace
terraform apply -var-file=staging.tfvars
```

### 3. Lock Resources

Use `-lock=true` (default) to prevent concurrent modifications:

```bash
terraform apply -lock=true tfplan
```

### 4. Regular Backups

```bash
# Backup state file
cp terraform.tfstate terraform.tfstate.$(date +%Y%m%d-%H%M%S).backup

# Store in S3
aws s3 cp terraform.tfstate s3://eshop-terraform-state/
```

### 5. Cost Optimization

```hcl
# Use spot instances in non-production
# instance_type = "t2.micro"  # Free tier eligible

# Scale down during off-hours
# Use lifecycle rules for S3 backups
```

---

## Destruction

### Delete All Resources

```bash
terraform destroy
```

This will:
- Terminate EC2 instance
- Delete security groups
- Delete VPC and networking
- Delete CloudWatch alarms
- Delete S3 bucket (if empty)

### Keep Some Resources

Edit Terraform to use `ignore_changes` or remove resources from `.tf` files before destroying.

---

## Advanced Topics

### Custom VPC

Modify `ec2.tf` to use existing VPC:

```hcl
# Change VPC reference
data "aws_vpc" "main" {
  id = "vpc-xxxxx"
}
```

### Load Balancer

Add to `ec2.tf`:

```hcl
resource "aws_lb" "eshop" {
  name               = "eshop-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.eshop.id]
  subnets            = [aws_subnet.main.id]
}
```

### Auto Scaling

Create `asg.tf`:

```hcl
resource "aws_autoscaling_group" "eshop" {
  name                = "eshop-asg"
  vpc_zone_identifier = [aws_subnet.main.id]
  min_size            = 1
  max_size            = 5
  desired_capacity    = 2
  
  launch_template {
    id      = aws_launch_template.eshop.id
    version = "$Latest"
  }
}
```

---

## Support

For issues:

1. Check Terraform documentation: https://www.terraform.io/docs
2. Check AWS documentation: https://docs.aws.amazon.com
3. Review logs: `cat /var/log/user-data.log`
4. Check GitHub issues

---

## Files Description

| File | Purpose |
|------|---------|
| `main.tf` | Provider configuration |
| `variables.tf` | Input variables |
| `ec2.tf` | EC2 and networking resources |
| `outputs.tf` | Output values |
| `user-data.sh` | Instance initialization script |
| `terraform.tfvars.example` | Variable example file |
| `.gitignore` | Git ignore rules |

---

**Happy Terraforming! 🚀**
