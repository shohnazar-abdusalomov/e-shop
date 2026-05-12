#!/bin/bash
set -e

echo "=========================================="
echo "E-SHOP Deployment Script"
echo "=========================================="

# Configuration
APP_DIR="/var/www/eshop"
REPO_URL="${1:-https://github.com/your-username/your-repo.git}"
BRANCH="${2:-main}"

echo "App Directory: $APP_DIR"
echo "Repository: $REPO_URL"
echo "Branch: $BRANCH"

# 1. Navigate to app directory
echo ""
echo "1. Navigating to app directory..."
if [ ! -d "$APP_DIR" ]; then
    mkdir -p "$APP_DIR"
fi
cd "$APP_DIR"

# 2. Clone or pull repository
echo "2. Cloning/Pulling repository..."
if [ -d ".git" ]; then
    echo "Repository already exists, pulling latest changes..."
    git fetch origin
    git checkout $BRANCH
    git pull origin $BRANCH
else
    echo "Cloning repository..."
    git clone -b $BRANCH $REPO_URL .
fi

# 3. Install dependencies
echo "3. Installing dependencies..."
cd client
npm ci --production
npm install --production

# 4. Build for production
echo "4. Building application for production..."
npm run build

# 5. Stop PM2 app if running
echo "5. Stopping PM2 app..."
pm2 delete eshop-app 2>/dev/null || true

# 6. Wait for build to complete
sleep 2

# 7. Start app with PM2
echo "6. Starting application with PM2..."
pm2 start ecosystem.config.js --name eshop-app

# 8. Save PM2 config
echo "7. Saving PM2 startup config..."
pm2 save

# 9. Enable PM2 startup
echo "8. Enabling PM2 startup on system reboot..."
sudo env PATH=$PATH:/usr/bin /usr/local/lib/node_modules/pm2/bin/pm2 startup systemd -u $USER --hp /home/$USER

# 10. Test Nginx
echo "9. Testing Nginx configuration..."
sudo nginx -t

# 11. Restart Nginx
echo "10. Restarting Nginx..."
sudo systemctl restart nginx

echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "Check app status:"
echo "  pm2 status"
echo "  pm2 logs eshop-app"
echo ""
echo "View Nginx logs:"
echo "  sudo tail -f /var/log/nginx/eshop_access.log"
echo "  sudo tail -f /var/log/nginx/eshop_error.log"
echo "=========================================="
