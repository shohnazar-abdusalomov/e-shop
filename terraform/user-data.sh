#!/bin/bash
set -e

# Log all output
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=================================="
echo "E-SHOP Auto-Deployment Started"
echo "=================================="
echo "Domain: ${domain_name}"
echo "Email: ${email}"
echo "=================================="

# Update system
apt-get update
apt-get upgrade -y

# Install Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Install tools
apt-get install -y nginx git certbot python3-certbot-nginx curl wget

# Install PM2 globally
npm install -g pm2

echo "✅ System packages installed"

# Setup app directory
mkdir -p /var/www/eshop
chown -R ubuntu:ubuntu /var/www/eshop
cd /var/www/eshop

echo "✅ App directory created"

# Clone repository
sudo -u ubuntu git clone https://github.com/shohnazar-abdusalomov/e-shop.git .

echo "✅ Repository cloned"

# Install and build
cd /var/www/eshop/client
sudo -u ubuntu npm ci --production
sudo -u ubuntu npm install --production

echo "✅ Dependencies installed"

# Build application
sudo -u ubuntu npm run build

echo "✅ Application built"

# Setup Nginx
sudo cp /var/www/eshop/nginx.conf /etc/nginx/sites-available/eshop
sed -i "s/your-domain.com/${domain_name}/g" /etc/nginx/sites-available/eshop
sed -i "s/www.your-domain.com/www.${domain_name}/g" /etc/nginx/sites-available/eshop
ln -sf /etc/nginx/sites-available/eshop /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t

# Start and enable Nginx
systemctl start nginx
systemctl enable nginx

echo "✅ Nginx configured and started"

# Setup PM2
cd /var/www/eshop/client
sudo -u ubuntu cp /var/www/eshop/ecosystem.config.js ./

# Start app with PM2
sudo -u ubuntu pm2 start ecosystem.config.js --name eshop-app
sudo -u ubuntu pm2 save

# Enable PM2 startup on reboot
env PATH=$PATH:/usr/bin /usr/local/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu

echo "✅ PM2 configured and app started"

# Setup firewall
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

echo "✅ Firewall configured"

# Setup SSL if domain is not default
if [ "${domain_name}" != "your-domain.com" ]; then
  echo "Setting up SSL certificate for ${domain_name}..."
  certbot certonly --nginx \
    -d ${domain_name} \
    -d www.${domain_name} \
    --non-interactive \
    --agree-tos \
    -m ${email} || echo "SSL setup note: Domain may need manual verification"
  
  systemctl reload nginx
  echo "✅ SSL certificate configured"
else
  echo "⚠️ Using default domain. To enable SSL, update domain in later stages."
fi

echo ""
echo "=================================="
echo "✅ Auto-Deployment Complete!"
echo "=================================="
echo ""
echo "Application Status:"
sudo -u ubuntu pm2 status
echo ""
echo "Nginx Status:"
systemctl status nginx --no-pager | head -5
echo ""
echo "Access your application at:"
echo "  http://${domain_name}"
if [ "${domain_name}" != "your-domain.com" ]; then
  echo "  https://${domain_name}"
fi
echo ""
