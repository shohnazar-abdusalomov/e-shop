# E-SHOP AWS EC2 Deployment Guide

## Complete Step-by-Step Guide

### 📋 Prerequisites

- AWS Account
- EC2 instance (Ubuntu 22.04 recommended)
- Domain name (optional but recommended)
- SSH key pair

---

## Step 1: Launch EC2 Instance

### 1.1 Create Instance

1. Go to AWS Console → EC2 → Launch Instance
2. **Image**: Ubuntu 22.04 LTS (Free Tier eligible)
3. **Instance Type**: t2.micro (Free Tier) or t2.small
4. **Storage**: 30 GB minimum
5. **Security Group**:
   - Allow SSH (22) from your IP
   - Allow HTTP (80) from anywhere
   - Allow HTTPS (443) from anywhere
6. **Key Pair**: Create new or use existing
7. Launch instance

### 1.2 Connect to Instance

```bash
# Give permission to key file
chmod 400 your-key.pem

# SSH into instance
ssh -i your-key.pem ubuntu@your-ec2-ip-or-domain
```

---

## Step 2: Run Initial Setup

### 2.1 Upload and run setup script

```bash
# On your local machine
scp -i your-key.pem ec2-setup.sh ubuntu@your-ec2-ip:/tmp/

# SSH into instance
ssh -i your-key.pem ubuntu@your-ec2-ip

# Run setup script
chmod +x /tmp/ec2-setup.sh
/tmp/ec2-setup.sh
```

This will install:
- Node.js 18
- npm
- Nginx
- PM2
- Git
- Certbot (SSL)
- UFW Firewall

---

## Step 3: Clone Repository

```bash
# SSH into EC2
ssh -i your-key.pem ubuntu@your-ec2-ip

# Clone your GitHub repository
cd /var/www/eshop
git clone https://github.com/your-username/your-repo.git .

# Or if you want to use different branch
git clone -b main https://github.com/your-username/your-repo.git .
```

---

## Step 4: Configure Nginx

### 4.1 Copy Nginx configuration

```bash
# Copy nginx config to the right location
sudo cp /var/www/eshop/nginx.conf /etc/nginx/sites-available/eshop

# Enable the site
sudo ln -s /etc/nginx/sites-available/eshop /etc/nginx/sites-enabled/

# Disable default site (optional)
sudo rm /etc/nginx/sites-enabled/default

# Test configuration
sudo nginx -t

# Should see: "nginx: configuration file test is successful"
```

### 4.2 Update domain in Nginx config

Edit `/etc/nginx/sites-available/eshop` and replace:
- `your-domain.com` with your actual domain
- `www.your-domain.com` with your www version

---

## Step 5: Deploy Application

### 5.1 Run deployment script

```bash
# Make script executable
chmod +x /var/www/eshop/deploy.sh

# Deploy with GitHub repo URL
./deploy.sh https://github.com/your-username/your-repo.git main

# Or just run without parameters (uses defaults from script)
./deploy.sh
```

This will:
1. Pull latest code
2. Install dependencies
3. Build for production
4. Start app with PM2
5. Restart Nginx

---

## Step 6: Setup SSL Certificate (HTTPS)

### 6.1 Point domain to EC2

**Update your domain's DNS records:**

- **A Record**: Point to your EC2 Elastic IP
- Wait 15-30 minutes for DNS propagation

**Check DNS propagation:**
```bash
nslookup your-domain.com
```

### 6.2 Run SSL setup

```bash
# Make script executable
chmod +x /var/www/eshop/ssl-setup.sh

# Run SSL setup with your domain
./ssl-setup.sh your-domain.com
```

This will:
1. Update Nginx config with correct domain
2. Get SSL certificate from Let's Encrypt
3. Set up automatic renewal

---

## Step 7: Verify Deployment

### 7.1 Check PM2 status

```bash
pm2 status
pm2 logs eshop-app
```

### 7.2 Check Nginx status

```bash
sudo systemctl status nginx
sudo tail -f /var/log/nginx/eshop_access.log
```

### 7.3 Test SSL

```bash
# Visit your domain
https://your-domain.com

# Check certificate
curl -I https://your-domain.com
```

---

## 🔧 Useful Commands

### PM2 Management

```bash
# View running processes
pm2 status

# View logs
pm2 logs eshop-app

# Stop app
pm2 stop eshop-app

# Restart app
pm2 restart eshop-app

# Delete app
pm2 delete eshop-app

# Restart all on reboot
pm2 startup
pm2 save
```

### Nginx Management

```bash
# Check status
sudo systemctl status nginx

# Start
sudo systemctl start nginx

# Stop
sudo systemctl stop nginx

# Restart
sudo systemctl restart nginx

# Reload config (without downtime)
sudo systemctl reload nginx

# View access logs
sudo tail -f /var/log/nginx/eshop_access.log

# View error logs
sudo tail -f /var/log/nginx/eshop_error.log
```

### Git Management

```bash
# Pull latest changes
cd /var/www/eshop && git pull origin main

# Check status
git status

# View logs
git log --oneline -10
```

---

## 🐛 Troubleshooting

### App not running

```bash
# Check PM2 logs
pm2 logs eshop-app

# Check if port is in use
sudo lsof -i :3000

# Restart app
pm2 restart eshop-app
```

### Nginx not working

```bash
# Test config
sudo nginx -t

# Check if Nginx is running
sudo systemctl status nginx

# View error logs
sudo tail -f /var/log/nginx/eshop_error.log
```

### SSL certificate issues

```bash
# View certificates
sudo certbot certificates

# Renew certificates
sudo certbot renew

# Force renewal
sudo certbot renew --force-renewal
```

### Permission issues

```bash
# Fix ownership
sudo chown -R ubuntu:ubuntu /var/www/eshop

# Fix permissions
chmod -R 755 /var/www/eshop
```

---

## 🔒 Security Recommendations

### 1. Update System Regularly

```bash
sudo apt-get update
sudo apt-get upgrade -y
```

### 2. Enable UFW Firewall

```bash
sudo ufw status
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### 3. Set up SSH Key-Only Access

Edit `/etc/ssh/sshd_config`:
```bash
sudo nano /etc/ssh/sshd_config

# Set these:
PasswordAuthentication no
PubkeyAuthentication yes
```

### 4. Use Elastic IP

1. Go to AWS Console → Elastic IPs
2. Allocate address
3. Associate with your EC2 instance

### 5. Enable CloudWatch Monitoring

1. Set up CloudWatch alarms
2. Monitor CPU, memory, disk usage

### 6. Regular Backups

```bash
# Backup application
sudo tar -czf eshop-backup.tar.gz /var/www/eshop

# Backup to S3
aws s3 cp eshop-backup.tar.gz s3://your-bucket/backups/
```

---

## 📊 Monitoring

### Check System Resources

```bash
# CPU and memory usage
top

# Disk usage
df -h

# Network connections
netstat -tulpn

# Process details
ps aux | grep node
```

### View Application Logs

```bash
# Real-time logs
pm2 logs eshop-app --lines 100

# Nginx access logs
sudo tail -100 /var/log/nginx/eshop_access.log

# Nginx error logs
sudo tail -100 /var/log/nginx/eshop_error.log
```

---

## 🚀 Continuous Deployment (Optional)

### Set up GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to EC2

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Deploy to EC2
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.HOST }}
          username: ubuntu
          key: ${{ secrets.SSH_KEY }}
          script: |
            cd /var/www/eshop
            git pull origin main
            cd client
            npm ci --production
            npm run build
            pm2 restart eshop-app
```

Then add secrets to GitHub:
- `HOST`: Your EC2 IP or domain
- `SSH_KEY`: Your private SSH key

---

## ❌ Rollback

If something goes wrong:

```bash
# Stop app
pm2 stop eshop-app

# Revert to previous commit
cd /var/www/eshop
git revert HEAD
git push origin main

# Deploy again
./deploy.sh

# Check status
pm2 status
```

---

## 📞 Support

For issues:
1. Check logs: `pm2 logs`
2. Check system: `top`, `df -h`
3. Check Nginx: `sudo nginx -t`
4. Check DNS: `nslookup your-domain.com`
5. Check firewall: `sudo ufw status`

---

**Good luck with your deployment! 🎉**
