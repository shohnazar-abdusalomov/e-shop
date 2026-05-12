# Quick Deployment Checklist

## ✅ Pre-Deployment

- [ ] AWS account active and working
- [ ] GitHub repository ready
- [ ] Domain name registered
- [ ] SSH key pair created and saved
- [ ] EC2 security groups configured

## ✅ Deployment Steps

### 1. Launch EC2 Instance
- [ ] Instance type: t2.micro or t2.small
- [ ] OS: Ubuntu 22.04 LTS
- [ ] Storage: 30GB+
- [ ] Security groups: SSH, HTTP, HTTPS open
- [ ] Elastic IP attached

### 2. Initial Setup
- [ ] SSH connected to EC2
- [ ] `ec2-setup.sh` executed successfully
- [ ] Node.js installed: `node --version`
- [ ] npm installed: `npm --version`
- [ ] Nginx installed: `sudo nginx -v`

### 3. Repository
- [ ] Repository cloned to `/var/www/eshop`
- [ ] Git configured
- [ ] Latest code pulled

### 4. Nginx Configuration
- [ ] Nginx config copied to `/etc/nginx/sites-available/eshop`
- [ ] Nginx config tested: `sudo nginx -t` ✓
- [ ] Nginx restarted: `sudo systemctl restart nginx`

### 5. Application Deployment
- [ ] `deploy.sh` executed
- [ ] Dependencies installed
- [ ] Build successful
- [ ] App started with PM2

### 6. SSL Certificate
- [ ] Domain DNS records updated
- [ ] DNS propagation verified: `nslookup your-domain.com`
- [ ] `ssl-setup.sh` executed
- [ ] HTTPS working: `https://your-domain.com`

### 7. Verification
- [ ] App running: `pm2 status`
- [ ] Nginx running: `sudo systemctl status nginx`
- [ ] Website accessible
- [ ] No error in logs

---

## 🔍 Quick Status Checks

```bash
# Check app status
pm2 status

# View app logs
pm2 logs eshop-app

# Check Nginx status
sudo systemctl status nginx

# Check server resources
top

# Check disk space
df -h

# Check if ports are open
netstat -tulpn | grep LISTEN
```

---

## 🚀 Commands Cheat Sheet

### Deployment
```bash
./deploy.sh                          # Deploy app
./ssl-setup.sh your-domain.com      # Setup SSL
```

### PM2
```bash
pm2 status                           # View status
pm2 logs eshop-app                   # View logs
pm2 restart eshop-app                # Restart app
pm2 stop eshop-app                   # Stop app
pm2 delete eshop-app                 # Delete app
pm2 save                             # Save startup config
```

### Nginx
```bash
sudo nginx -t                        # Test config
sudo systemctl start nginx           # Start Nginx
sudo systemctl stop nginx            # Stop Nginx
sudo systemctl restart nginx         # Restart Nginx
sudo tail -f /var/log/nginx/eshop_access.log  # View access logs
```

### Git
```bash
git pull origin main                 # Pull latest code
git status                           # Check status
git log --oneline -10                # View recent commits
```

---

## 🐛 Common Issues

### App won't start
- Check logs: `pm2 logs eshop-app`
- Check ports: `sudo lsof -i :3000`
- Check build: `cd /var/www/eshop/client && npm run build`

### Website not accessible
- Check DNS: `nslookup your-domain.com`
- Check Nginx: `sudo nginx -t`
- Check firewall: `sudo ufw status`
- Check app: `pm2 status`

### SSL certificate issues
- Check certificates: `sudo certbot certificates`
- Check domain DNS
- View error logs: `sudo tail -f /var/log/nginx/eshop_error.log`

### Permission denied errors
- Fix ownership: `sudo chown -R ubuntu:ubuntu /var/www/eshop`
- Fix permissions: `chmod -R 755 /var/www/eshop`

---

## 📞 First Steps If Something Breaks

1. **Check app logs**
   ```bash
   pm2 logs eshop-app
   ```

2. **Check Nginx logs**
   ```bash
   sudo tail -f /var/log/nginx/eshop_error.log
   ```

3. **Check system resources**
   ```bash
   top
   df -h
   ```

4. **Restart app**
   ```bash
   pm2 restart eshop-app
   ```

5. **Check DNS**
   ```bash
   nslookup your-domain.com
   ```

6. **View Nginx config**
   ```bash
   sudo nginx -t
   ```

---

## 📋 Configuration Files

| File | Purpose |
|------|---------|
| `ec2-setup.sh` | Initial EC2 setup |
| `nginx.conf` | Nginx web server config |
| `ecosystem.config.js` | PM2 app config |
| `deploy.sh` | Deployment script |
| `ssl-setup.sh` | SSL certificate setup |
| `.env.production` | Environment variables |
| `DEPLOYMENT_GUIDE.md` | Full deployment guide |

---

## 🎯 Next Steps After Deployment

1. **Monitor application**
   - Set up CloudWatch alarms
   - Monitor error logs

2. **Set up auto-renewal for SSL**
   - Already handled by `ssl-setup.sh`
   - Verify: `sudo systemctl status certbot.timer`

3. **Configure backups**
   - Regular backup of `/var/www/eshop`
   - Upload to S3 or external storage

4. **Set up CI/CD** (optional)
   - Use GitHub Actions for auto-deployment
   - See DEPLOYMENT_GUIDE.md for details

5. **Security hardening**
   - Disable password SSH
   - Enable fail2ban
   - Regular security updates

---

**All set! Your app should be live! 🎉**
