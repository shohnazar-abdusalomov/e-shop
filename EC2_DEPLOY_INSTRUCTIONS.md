# 🚀 EC2 DEPLOYMENT INSTRUCTIONS

## GitHub Repo Successfully Updated! ✅

Repository: https://github.com/shohnazar-abdusalomov/e-shop

Barcha deployment fayllar GitHub ga yuklandi!

---

## 📋 EC2 ga Deploy Qilish (3 Usul)

### ⚡ USUL 1: One-Command Deploy (Eng Oson!) 🔥

```bash
# EC2 ga SSH qilib kiring:
ssh -i your-key.pem ubuntu@your-ec2-ip

# Va shu buyruq bajaring:
curl -fsSL https://raw.githubusercontent.com/shohnazar-abdusalomov/e-shop/master/full-deploy.sh | bash -s "your-domain.com"
```

**Bu hamma narsani o'zi qiladi:**
- ✅ System setup (Node.js, Nginx, PM2)
- ✅ Repository clone qilish
- ✅ App build qilish  
- ✅ Nginx configure qilish
- ✅ PM2 setup qilish
- ✅ SSL setup qilish

---

### 📝 USUL 2: Step-by-Step Deploy

#### 1. EC2 Instance Yaratish

1. AWS Console ga kiring
2. **EC2 → Launch Instance**
3. **Image:** Ubuntu 22.04 LTS
4. **Type:** t2.micro (free)
5. **Storage:** 30GB
6. **Security Group:**
   - Port 22 (SSH): Your IP dan
   - Port 80 (HTTP): 0.0.0.0/0
   - Port 443 (HTTPS): 0.0.0.0/0
7. **Key Pair:** Create va saqlang
8. **Launch!**

#### 2. EC2 ga Ulanish

```bash
chmod 400 your-key.pem
ssh -i your-key.pem ubuntu@your-ec2-ip
```

#### 3. Repository Klonlash

```bash
mkdir -p /var/www/eshop
cd /var/www/eshop
git clone https://github.com/shohnazar-abdusalomov/e-shop.git .
```

#### 4. Deploy Script Ishlatish

```bash
# Script'ni executable qiling
chmod +x full-deploy.sh

# Domain bilan deploy
./full-deploy.sh your-domain.com

# Yoki IP orqali (SSL yo'q)
./full-deploy.sh
```

#### 5. Domain Setup (agar domain bo'lsa)

1. Domain registrator ga kiring
2. Nameserver o'zgaritring: AWS Route 53 ga
3. A Record: EC2 Elastic IP ko'rsating
4. DNS propagation kutish (15-30 minut)

#### 6. Verify Qilish

```bash
# App status
pm2 status

# Nginx status  
sudo systemctl status nginx

# Logs
pm2 logs eshop-app
```

---

### 🎯 USUL 3: Manual Commands (Advanced)

Agar script'dan foydalanmasangiz:

```bash
# SSH qiling
ssh -i your-key.pem ubuntu@your-ec2-ip

# System update
sudo apt-get update && sudo apt-get upgrade -y

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install tools
sudo apt-get install -y nginx git certbot python3-certbot-nginx
sudo npm install -g pm2

# Clone repo
mkdir -p /var/www/eshop && cd /var/www/eshop
git clone https://github.com/shohnazar-abdusalomov/e-shop.git .

# Install & Build
cd client
npm ci --production && npm install --production
npm run build

# Setup Nginx
sudo cp ../nginx.conf /etc/nginx/sites-available/eshop
sudo sed -i 's/your-domain.com/YOUR-DOMAIN/g' /etc/nginx/sites-available/eshop
sudo ln -sf /etc/nginx/sites-available/eshop /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl restart nginx

# Setup PM2
pm2 start ecosystem.config.js
pm2 save

# Setup SSL
sudo certbot certonly --nginx -d YOUR-DOMAIN -d www.YOUR-DOMAIN --non-interactive --agree-tos -m admin@YOUR-DOMAIN
sudo systemctl reload nginx
```

---

## 🌐 Domain bo'lmasa?

Agar domain yo'q bo'lsa, EC2 Elastic IP dan foydalaning:

```
http://your-ec2-elastic-ip
```

Faqat HTTP bo'ladi (HTTPS yo'q). Domain qo'shib, SSL olish mumkin.

---

## 🔧 Kerakli Commands

### App bilan ishlash

```bash
# Status ko'rish
pm2 status

# Logs ko'rish
pm2 logs eshop-app

# Restart qilish
pm2 restart eshop-app

# Stop qilish
pm2 stop eshop-app
```

### Nginx bilan ishlash

```bash
# Status
sudo systemctl status nginx

# Restart
sudo systemctl restart nginx

# Error logs
sudo tail -f /var/log/nginx/eshop_error.log

# Access logs
sudo tail -f /var/log/nginx/eshop_access.log
```

### Code update qilish

```bash
cd /var/www/eshop
git pull origin master
cd client
npm run build
pm2 restart eshop-app
```

---

## ⚠️ Agar Problem Bolsa?

### App ishlamayapti

```bash
pm2 logs eshop-app
# Error ni ko'ring va fix qiling
```

### Website accessible emas

```bash
# DNS check
nslookup your-domain.com

# Nginx check
sudo nginx -t
sudo systemctl status nginx

# Firewall check
sudo ufw status

# Port check
sudo lsof -i :80
```

### SSL error

```bash
sudo certbot certificates
sudo tail -f /var/log/nginx/eshop_error.log
```

### Permission error

```bash
sudo chown -R ubuntu:ubuntu /var/www/eshop
chmod -R 755 /var/www/eshop
```

---

## 📚 Dokumentatsiya

Repo'da mavjud:

- **START_HERE.md** - Boshlang'ich guide
- **DEPLOYMENT_GUIDE.md** - To'liq guide
- **QUICK_CHECKLIST.md** - Qisqa reference
- **DOCKER_DEPLOYMENT_GUIDE.md** - Docker variant

---

## ✅ Deployment Checklist

- [ ] AWS account ready
- [ ] EC2 instance created
- [ ] SSH key pair downloaded
- [ ] Elastic IP allocated
- [ ] Security groups configured
- [ ] SSH connection tested
- [ ] `full-deploy.sh` script executed
- [ ] Domain DNS configured (if using domain)
- [ ] Website accessible
- [ ] SSL certificate working (if domain)
- [ ] App logs checked for errors

---

## 🎯 Quick Reference

```bash
# Clone va deploy (hammasi bitta)
curl -fsSL https://raw.githubusercontent.com/shohnazar-abdusalomov/e-shop/master/full-deploy.sh | bash -s "your-domain.com"

# Status check
pm2 status && sudo systemctl status nginx

# Logs
pm2 logs eshop-app

# Update code
cd /var/www/eshop && git pull && cd client && npm run build && pm2 restart eshop-app
```

---

## 🚀 Tayyor Bo'ldilar?

1. **EC2 instance launch qiling**
2. **SSH qilib kiring**
3. **`full-deploy.sh` script ishlatish** ← Hammasi bu!

```bash
curl -fsSL https://raw.githubusercontent.com/shohnazar-abdusalomov/e-shop/master/full-deploy.sh | bash -s "your-domain.com"
```

**Barcha narsani o'zi qiladi!** ✨

---

## 📞 Savollar?

- DEPLOYMENT_GUIDE.md o'qing
- Logs ko'ring: `pm2 logs eshop-app`
- Nginx config check: `sudo nginx -t`
- System resources: `top` va `df -h`

---

**Happy Deployment! 🎉**

Repository: https://github.com/shohnazar-abdusalomov/e-shop
