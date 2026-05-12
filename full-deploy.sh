#!/bin/bash
set -e

echo "=========================================="
echo "E-SHOP Complete AWS EC2 Deployment"
echo "=========================================="

# Variables
REPO_URL="https://github.com/shohnazar-abdusalomov/e-shop.git"
BRANCH="master"
DOMAIN="${1:-your-domain.com}"
APP_DIR="/var/www/eshop"

echo ""
echo "📦 Repository: $REPO_URL"
echo "🔗 Branch: $BRANCH"
echo "🌐 Domain: $DOMAIN"
echo "📁 App Directory: $APP_DIR"
echo ""

# ============================================
# STEP 1: Initial System Setup
# ============================================
echo "STEP 1: System Setup"
echo "---"

# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install Node.js and npm
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Nginx
sudo apt-get install -y nginx

# Install PM2
sudo npm install -g pm2

# Install Git
sudo apt-get install -y git

# Install Certbot for SSL
sudo apt-get install -y certbot python3-certbot-nginx

# Setup UFW Firewall
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

echo "✅ System setup complete"
echo ""

# ============================================
# STEP 2: Clone Repository
# ============================================
echo "STEP 2: Clone Repository"
echo "---"

sudo mkdir -p $APP_DIR
sudo chown -R $USER:$USER $APP_DIR

cd $APP_DIR

if [ -d ".git" ]; then
    echo "Repository already exists, pulling latest..."
    git fetch origin
    git checkout $BRANCH
    git pull origin $BRANCH
else
    echo "Cloning repository..."
    git clone -b $BRANCH $REPO_URL .
fi

echo "✅ Repository cloned/updated"
echo ""

# ============================================
# STEP 3: Setup Nginx
# ============================================
echo "STEP 3: Setup Nginx"
echo "---"

# Copy and configure nginx
sudo cp $APP_DIR/nginx.conf /etc/nginx/sites-available/eshop

# Update domain in nginx config
sudo sed -i "s/your-domain.com/$DOMAIN/g" /etc/nginx/sites-available/eshop
sudo sed -i "s/www.your-domain.com/www.$DOMAIN/g" /etc/nginx/sites-available/eshop

# Enable site
sudo ln -sf /etc/nginx/sites-available/eshop /etc/nginx/sites-enabled/

# Remove default site
sudo rm -f /etc/nginx/sites-enabled/default

# Test nginx config
sudo nginx -t

echo "✅ Nginx configured"
echo ""

# ============================================
# STEP 4: Build and Deploy App
# ============================================
echo "STEP 4: Build and Deploy Application"
echo "---"

cd $APP_DIR/client

# Install dependencies
echo "Installing dependencies..."
npm ci --production
npm install --production

# Build for production
echo "Building application..."
npm run build

echo "✅ Application built"
echo ""

# ============================================
# STEP 5: Setup PM2
# ============================================
echo "STEP 5: Setup PM2"
echo "---"

# Stop any existing PM2 process
pm2 delete eshop-app 2>/dev/null || true

# Copy ecosystem config
cp $APP_DIR/ecosystem.config.js ./

# Start app with PM2
pm2 start ecosystem.config.js --name eshop-app

# Save PM2 config
pm2 save

# Enable PM2 startup on reboot
sudo env PATH=$PATH:/usr/bin /usr/local/lib/node_modules/pm2/bin/pm2 startup systemd -u $USER --hp /home/$USER

echo "✅ PM2 configured and app started"
echo ""

# ============================================
# STEP 6: Restart Nginx
# ============================================
echo "STEP 6: Start Web Server"
echo "---"

sudo systemctl restart nginx
sudo systemctl enable nginx

echo "✅ Nginx started and enabled"
echo ""

# ============================================
# STEP 7: Setup SSL (if domain provided)
# ============================================
if [ "$DOMAIN" != "your-domain.com" ]; then
    echo "STEP 7: Setup SSL Certificate"
    echo "---"
    
    # Wait for nginx to be ready
    sleep 2
    
    # Create SSL certificate
    sudo certbot certonly --nginx \
        -d $DOMAIN \
        -d www.$DOMAIN \
        --non-interactive \
        --agree-tos \
        -m admin@$DOMAIN 2>/dev/null || echo "Note: SSL setup may require manual domain verification"
    
    # Reload nginx to apply SSL
    sudo systemctl reload nginx
    
    # Set up auto-renewal
    sudo systemctl enable certbot.timer
    sudo systemctl start certbot.timer
    
    echo "✅ SSL certificate configured (if domain verified)"
else
    echo "STEP 7: SSL Certificate"
    echo "---"
    echo "⚠️  Domain not provided or still 'your-domain.com'"
    echo "To setup SSL later, run:"
    echo "  ./ssl-setup.sh your-real-domain.com"
fi

echo ""

# ============================================
# VERIFICATION
# ============================================
echo "=========================================="
echo "✅ DEPLOYMENT COMPLETE!"
echo "=========================================="
echo ""
echo "🔍 Verification:"
echo ""
echo "1️⃣  Check app status:"
pm2 status

echo ""
echo "2️⃣  Check Nginx status:"
sudo systemctl status nginx --no-pager | head -5

echo ""
echo "3️⃣  View app logs:"
echo "   pm2 logs eshop-app"

echo ""
echo "4️⃣  View Nginx access logs:"
echo "   sudo tail -f /var/log/nginx/eshop_access.log"

echo ""
echo "5️⃣  Test your site:"
if [ "$DOMAIN" != "your-domain.com" ]; then
    echo "   https://$DOMAIN"
else
    echo "   http://your-ec2-ip"
fi

echo ""
echo "📚 Documentation:"
echo "   - START_HERE.md"
echo "   - DEPLOYMENT_GUIDE.md"
echo "   - QUICK_CHECKLIST.md"

echo ""
echo "=========================================="
