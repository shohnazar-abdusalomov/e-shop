# AWS CloudFormation E-SHOP Deployment Guide

## Overview

CloudFormation template automatically creates:
- VPC with public subnet
- Security group with SSH, HTTP, HTTPS
- EC2 instance (t2.micro free tier)
- Elastic IP
- IAM role and instance profile
- CloudWatch log group and alarms
- S3 backup bucket
- Auto-deployment and SSL setup

---

## Prerequisites

1. **AWS Account** - with appropriate permissions
2. **EC2 Key Pair** - created in AWS Console
3. **Domain Name** (optional) - for SSL certificate

---

## Quick Deployment (2 Ways)

### Method 1: AWS Console (Easiest)

1. **Go to CloudFormation Console**
   - https://console.aws.amazon.com/cloudformation

2. **Click "Create Stack"**
   - Choose "Upload a template file"
   - Upload `cloudformation-template.yaml`
   - Click "Next"

3. **Configure Stack Details**
   - Stack Name: `eshop-stack`
   - InstanceType: `t2.micro` (free)
   - KeyName: Select your EC2 key pair
   - DomainName: `your-domain.com` (or default)
   - Email: `admin@your-domain.com`
   - Click "Next"

4. **Configure Stack Options** (Keep defaults)
   - Click "Next"

5. **Review**
   - Check "I acknowledge that AWS CloudFormation..."
   - Click "Create Stack"

6. **Wait for Stack Creation**
   - Status: `CREATE_IN_PROGRESS` → `CREATE_COMPLETE`
   - Takes ~10-15 minutes

7. **Get Outputs**
   - Click on Stack → Outputs tab
   - Get Instance Public IP and SSH command

### Method 2: AWS CLI

```bash
# Set variables
STACK_NAME="eshop-stack"
KEY_NAME="your-key-pair-name"
DOMAIN="your-domain.com"
EMAIL="admin@your-domain.com"

# Create stack
aws cloudformation create-stack \
  --stack-name $STACK_NAME \
  --template-body file://cloudformation-template.yaml \
  --parameters \
    ParameterKey=InstanceType,ParameterValue=t2.micro \
    ParameterKey=KeyName,ParameterValue=$KEY_NAME \
    ParameterKey=DomainName,ParameterValue=$DOMAIN \
    ParameterKey=Email,ParameterValue=$EMAIL \
    ParameterKey=EnvironmentName,ParameterValue=production \
  --capabilities CAPABILITY_NAMED_IAM

# Wait for stack to complete
aws cloudformation wait stack-create-complete \
  --stack-name $STACK_NAME

# Get stack outputs
aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --query 'Stacks[0].Outputs'
```

---

## Accessing Your Application

### After Stack Creation

1. **Get Instance IP**
   ```bash
   aws cloudformation describe-stacks \
     --stack-name eshop-stack \
     --query 'Stacks[0].Outputs[?OutputKey==`InstancePublicIP`].OutputValue' \
     --output text
   ```

2. **SSH into Instance**
   ```bash
   ssh -i your-key.pem ubuntu@<instance-ip>
   ```

3. **Access Application**
   - HTTP: `http://<instance-ip>`
   - HTTPS: `https://your-domain.com` (if domain configured)

---

## Monitoring

### CloudWatch

**View Alarms**
```bash
aws cloudwatch describe-alarms \
  --alarm-names eshop-instance-status-check eshop-high-cpu
```

**View Logs**
```bash
aws logs tail /eshop/application --follow
```

### On Instance

```bash
# SSH into instance
ssh -i your-key.pem ubuntu@<ip>

# Check app status
pm2 status

# View app logs
pm2 logs eshop-app

# View Nginx status
sudo systemctl status nginx

# View Nginx logs
sudo tail -f /var/log/nginx/eshop_access.log
```

---

## Stack Management

### View Stack Status

```bash
aws cloudformation describe-stacks \
  --stack-name eshop-stack \
  --query 'Stacks[0].{Name:StackName,Status:StackStatus,CreationTime:CreationTime}'
```

### Update Stack

```bash
# Modify template or parameters
aws cloudformation update-stack \
  --stack-name eshop-stack \
  --template-body file://cloudformation-template.yaml \
  --parameters \
    ParameterKey=InstanceType,ParameterValue=t2.small \
    UsePreviousValue=true
```

### Delete Stack

```bash
# This will delete ALL resources including EC2 instance
aws cloudformation delete-stack --stack-name eshop-stack

# Wait for deletion
aws cloudformation wait stack-delete-complete --stack-name eshop-stack
```

---

## Backup and Restore

### S3 Backup Bucket

Backup bucket name: `eshop-backups-<account-id>`

**Manual Backup**
```bash
# SSH into instance
ssh -i your-key.pem ubuntu@<ip>

# Create backup
tar -czf eshop-backup.tar.gz /var/www/eshop

# Upload to S3
aws s3 cp eshop-backup.tar.gz s3://eshop-backups-<account-id>/backups/eshop-$(date +%Y%m%d).tar.gz
```

**Restore**
```bash
# Download from S3
aws s3 cp s3://eshop-backups-<account-id>/backups/eshop-latest.tar.gz .

# Extract and restore
tar -xzf eshop-backup.tar.gz
sudo cp -r var/www/eshop/* /var/www/eshop/

# Restart
pm2 restart eshop-app
```

---

## SSL Certificate

### Automatic Setup (If Domain Provided)

If domain is not `your-domain.com`, SSL is automatically configured.

### Manual Setup

```bash
# SSH into instance
ssh -i your-key.pem ubuntu@<ip>

# Create certificate
sudo certbot certonly --nginx \
  -d your-domain.com \
  -d www.your-domain.com \
  --non-interactive \
  --agree-tos \
  -m admin@your-domain.com

# Reload Nginx
sudo systemctl reload nginx

# Verify
curl -I https://your-domain.com
```

### Renewal

```bash
# Automatic renewal is set up via certbot timer
sudo systemctl status certbot.timer

# Manual renewal
sudo certbot renew
```

---

## Troubleshooting

### Stack Creation Failed

1. **Check Stack Status**
   ```bash
   aws cloudformation describe-stack-events \
     --stack-name eshop-stack \
     --query 'StackEvents[0:5]'
   ```

2. **Check CloudFormation Logs**
   ```bash
   aws cloudformation describe-stacks \
     --stack-name eshop-stack \
     --query 'Stacks[0].StackStatusReason'
   ```

3. **Common Issues**
   - Invalid key pair name
   - Insufficient permissions
   - Resource quota exceeded

### Application Not Running

```bash
# SSH into instance
ssh -i your-key.pem ubuntu@<ip>

# Check deployment log
cat /var/log/user-data.log

# Check PM2
pm2 status
pm2 logs eshop-app

# Check Nginx
sudo nginx -t
sudo systemctl status nginx

# Restart
pm2 restart eshop-app
```

### Can't Connect via SSH

1. **Check security group**
   ```bash
   aws ec2 describe-security-groups \
     --filters Name=group-name,Values=eshop-sg \
     --query 'SecurityGroups[0].IpPermissions'
   ```

2. **Check instance status**
   ```bash
   aws ec2 describe-instances \
     --query 'Reservations[0].Instances[0].[InstanceId,State.Name,PublicIpAddress]'
   ```

3. **Wait for instance to be ready**
   - Usually takes 1-2 minutes after creation

---

## Cost Estimation

### Free Tier Eligible (12 months)

- **t2.micro**: Free
- **30GB EBS**: Free (20GB limit)
- **Elastic IP**: Free (if associated)
- **Data Transfer**: 1GB/month free

### Potential Costs After Free Tier

| Resource | Cost | Notes |
|----------|------|-------|
| t2.micro | ~$10/month | When free tier expires |
| EBS Storage | ~$1.04/month | 30GB at $0.035/GB |
| Data Transfer Out | Variable | First 1GB/month free |
| CloudWatch | ~$3-5/month | Depends on usage |

---

## Best Practices

### 1. Use Appropriate Key Pair

```bash
# Create secure key pair
aws ec2 create-key-pair --key-name eshop-prod \
  --query 'KeyMaterial' --output text > eshop-prod.pem
chmod 400 eshop-prod.pem
```

### 2. Configure Domain Before Deployment

Update DNS records before deploying:

```bash
# Get Elastic IP from CloudFormation outputs
# Add A record in your DNS provider pointing to this IP
```

### 3. Enable CloudWatch Monitoring

Already enabled in template for production environment.

### 4. Regular Backups

```bash
# Create automated backups
AWS_CRON="0 2 * * *"  # 2 AM daily
# Add to crontab on EC2 instance
```

### 5. Security Group Restrictions

Edit security group to restrict SSH:

```bash
# Allow SSH from specific IP only
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxx \
  --protocol tcp --port 22 \
  --cidr YOUR-IP/32
```

---

## Advanced Features

### Stack Parameters

Customize during creation:

| Parameter | Default | Options |
|-----------|---------|---------|
| InstanceType | t2.micro | t2.micro, t2.small, t2.medium |
| EnvironmentName | production | development, staging, production |

### Outputs

After stack creation, get outputs:

```bash
aws cloudformation describe-stacks \
  --stack-name eshop-stack \
  --query 'Stacks[0].Outputs' \
  --output table
```

---

## Cleanup

### Delete Everything

```bash
# Delete stack (removes all resources)
aws cloudformation delete-stack --stack-name eshop-stack

# Verify deletion
aws cloudformation describe-stacks --stack-name eshop-stack
```

### Keep Backups

Before deleting:

```bash
# Download backups from S3
aws s3 sync s3://eshop-backups-<account-id>/ ./backups/

# Store safely for later restoration
```

---

## Support

For issues:

1. **Check Template**: Review `cloudformation-template.yaml`
2. **View Logs**: Check `/var/log/user-data.log` on instance
3. **AWS Support**: Contact AWS support for account issues
4. **GitHub Issues**: Report issues in repository

---

**CloudFormation Stack Deployed! 🎉**

Next: SSH into instance and verify application status.

```bash
ssh -i your-key.pem ubuntu@<instance-ip>
pm2 status
curl http://localhost
```
