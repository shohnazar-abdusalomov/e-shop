#!/bin/bash
set -e

echo "=========================================="
echo "SSL Setup with Let's Encrypt"
echo "=========================================="

DOMAIN="${1:-your-domain.com}"

echo "Domain: $DOMAIN"
echo ""

# Check if domain is provided
if [ "$DOMAIN" = "your-domain.com" ]; then
    echo "ERROR: Please provide your domain"
    echo "Usage: ./ssl-setup.sh yourdomain.com"
    exit 1
fi

# 1. Update Nginx config with correct domain
echo "1. Updating Nginx configuration with domain..."
sudo sed -i "s/your-domain.com/$DOMAIN/g" /etc/nginx/sites-available/eshop
sudo sed -i "s/www.your-domain.com/www.$DOMAIN/g" /etc/nginx/sites-available/eshop

# 2. Test Nginx config
echo "2. Testing Nginx configuration..."
sudo nginx -t

# 3. Restart Nginx
echo "3. Restarting Nginx..."
sudo systemctl restart nginx

# 4. Create SSL certificate with Certbot
echo "4. Creating SSL certificate with Let's Encrypt..."
sudo certbot certonly --nginx \
    -d $DOMAIN \
    -d www.$DOMAIN \
    --non-interactive \
    --agree-tos \
    -m admin@$DOMAIN

# 5. Reload Nginx
echo "5. Reloading Nginx..."
sudo systemctl reload nginx

# 6. Set up auto-renewal
echo "6. Setting up automatic renewal..."
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

echo ""
echo "=========================================="
echo "SSL Setup Complete!"
echo "=========================================="
echo ""
echo "Your site is now secured with HTTPS"
echo "Certificate will auto-renew in 30 days"
echo ""
echo "Check certificate expiration:"
echo "  sudo certbot certificates"
echo ""
echo "Manual renewal:"
echo "  sudo certbot renew"
echo "=========================================="
