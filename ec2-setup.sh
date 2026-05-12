#!/bin/bash
set -e

echo "=========================================="
echo "E-SHOP AWS EC2 Setup Script"
echo "=========================================="

# Update system packages
echo "1. Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install Node.js and npm
echo "2. Installing Node.js and npm..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify Node.js installation
echo "Node.js version:"
node --version
echo "npm version:"
npm --version

# Install Nginx
echo "3. Installing Nginx..."
sudo apt-get install -y nginx

# Install PM2 globally
echo "4. Installing PM2..."
sudo npm install -g pm2

# Install Git
echo "5. Installing Git..."
sudo apt-get install -y git

# Install Certbot for SSL
echo "6. Installing Certbot for SSL..."
sudo apt-get install -y certbot python3-certbot-nginx

# Create app directory
echo "7. Creating app directory..."
sudo mkdir -p /var/www/eshop
sudo chown -R $USER:$USER /var/www/eshop

# Set up firewall (UFW)
echo "8. Setting up firewall..."
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

echo "=========================================="
echo "EC2 Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Clone your repository: git clone <your-repo> /var/www/eshop"
echo "2. Copy Nginx config: sudo cp nginx.conf /etc/nginx/sites-available/eshop"
echo "3. Enable Nginx site: sudo ln -s /etc/nginx/sites-available/eshop /etc/nginx/sites-enabled/"
echo "4. Test Nginx: sudo nginx -t"
echo "5. Start Nginx: sudo systemctl start nginx"
echo "6. Deploy app using deploy script"
echo "=========================================="
