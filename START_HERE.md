# 🚀 E-SHOP EC2 Deployment - READY TO GO!

Barcha deploy uchun zarur fayllar tayyorlandi! ✅

---

## 📁 Yaratilgan Fayllar

### Setup Scripts (EC2 da ishlatish uchun)
```
✅ ec2-setup.sh            - Birinchi o'rnatish
✅ deploy.sh              - App deploy qilish
✅ ssl-setup.sh           - SSL sertifikat setup
✅ install-docker.sh      - Docker o'rnatish (ixtiyoriy)
```

### Configuration Files
```
✅ nginx.conf             - Web server config
✅ ecosystem.config.js    - PM2 config
✅ docker-compose.yml     - Docker config (ixtiyoriy)
✅ Dockerfile             - Docker image (ixtiyoriy)
✅ .env.production        - Environment variables
```

### Documentation (O'qish uchun)
```
✅ DEPLOYMENT_GUIDE.md           - To'liq guide (Nginx+PM2)
✅ DOCKER_DEPLOYMENT_GUIDE.md    - Docker guide
✅ QUICK_CHECKLIST.md            - Tez reference
✅ README.md                     - Project info
```

---

## 🎯 Qanday Deploy Qilish?

### Faqat 3 usul mavjud:

#### **USUL 1: Traditional (Oson) ✨**
- Nginx + PM2 + Node.js
- Beginners uchun ideal
- Full control

#### **USUL 2: Docker (Zamonaviy) 🐳**
- Container based
- Production ready
- Easy scaling

#### **USUL 3: Custom Variant 🔧**
- O'zim sozlash uchun

---

## 📋 Step-by-Step (Usul 1)

### 1️⃣ EC2 Instance Yaratish
- AWS Console → Launch Instance
- Image: Ubuntu 22.04
- Type: t2.micro (free)
- Ports: 22, 80, 443 open

### 2️⃣ EC2 ga Connect Qilish
```bash
ssh -i your-key.pem ubuntu@your-ec2-ip
```

### 3️⃣ Setup Script Ishlatish
```bash
scp -i your-key.pem ec2-setup.sh ubuntu@your-ec2-ip:/tmp/
ssh -i your-key.pem ubuntu@your-ec2-ip
chmod +x /tmp/ec2-setup.sh
/tmp/ec2-setup.sh
```

### 4️⃣ Repository Clone Qilish
```bash
cd /var/www/eshop
git clone https://github.com/YOUR-USERNAME/YOUR-REPO.git .
```

### 5️⃣ Deploy Qilish
```bash
chmod +x deploy.sh
./deploy.sh
```

### 6️⃣ SSL Setup Qilish (Domain bilan)
```bash
# Avval domain'ni EC2 IP ga ko'rsating!
chmod +x ssl-setup.sh
./ssl-setup.sh your-domain.com
```

### 7️⃣ Verify Qilish
```bash
# Status check
pm2 status
sudo systemctl status nginx

# Visit your domain
https://your-domain.com
```

---

## 🐳 Usul 2: Docker (Zamonaviy)

```bash
# 1. Docker setup
./install-docker.sh

# 2. Clone repo
cd /var/www/eshop
git clone YOUR-REPO-URL .

# 3. Build va start
docker build -t eshop:latest .
docker-compose up -d

# 4. Check
docker ps
```

---

## 🔑 Important Things to Do

✅ **Oldin bilish kerak:**
- AWS account (Free Tier ishlatsa bo'ladi)
- Domain name (ixtiyoriy, IP orqali ham bo'ladi)
- GitHub access
- SSH key pair

✅ **Domain Setup (agar domain ishlatsa):**
1. Domain registrar dan Admin Panel ga kir
2. Nameserver o'zgar: AWS Route 53 yoki similar
3. A Record: EC2 Elastic IP ko'rsat
4. DNS propagation kutish (15-30 min)

✅ **Security (Production uchun):**
- SSH password disabled (EC2 setup script buni bajaradi)
- Firewall configured (UFW - ec2-setup.sh bajaradi)
- SSL enabled (ssl-setup.sh bajaradi)
- Regular backups

---

## 🚨 Agar Problem Bolsa?

### Problem 1: App ishlamayapti
```bash
pm2 logs eshop-app
```

### Problem 2: Website accessible emas
```bash
# DNS check
nslookup your-domain.com

# Nginx check
sudo nginx -t
sudo systemctl status nginx

# Firewall check
sudo ufw status
```

### Problem 3: SSL error
```bash
sudo certbot certificates
sudo tail -f /var/log/nginx/eshop_error.log
```

---

## 📞 Logs Checkout Qilish

```bash
# App logs
pm2 logs eshop-app

# Web server logs
sudo tail -f /var/log/nginx/eshop_access.log
sudo tail -f /var/log/nginx/eshop_error.log

# System logs
journalctl -u nginx -f
```

---

## 🎯 Recommended Checklist

- [ ] AWS account ready
- [ ] EC2 instance launched
- [ ] SSH connected
- [ ] ec2-setup.sh ran successfully
- [ ] Repository cloned
- [ ] deploy.sh executed
- [ ] App running (pm2 status)
- [ ] Domain pointing to EC2 IP (DNS)
- [ ] ssl-setup.sh ran
- [ ] Website accessible via HTTPS

---

## 📚 Dokumentatsiya

Barcha savollari javobini shu faylardan topa olasiz:
- **DEPLOYMENT_GUIDE.md** - To'liq guide
- **QUICK_CHECKLIST.md** - Qisqa reference
- **DOCKER_DEPLOYMENT_GUIDE.md** - Docker foydalanuvchilar uchun

---

## ⚡ One-Liner Commands

```bash
# Darsad deploy (domain bilan)
./ec2-setup.sh && git clone REPO . && ./deploy.sh && ./ssl-setup.sh domain.com

# Status check
pm2 status && sudo systemctl status nginx

# Logs
pm2 logs eshop-app

# Restart
pm2 restart eshop-app && sudo systemctl restart nginx
```

---

## 🎉 All Set!

Hamma tayyorlandi! Endi faqat:

1. AWS EC2 instance yaratish
2. SSH connect qilish  
3. Scripts ishlatish
4. Domain setup qilish
5. Enjoy! 🚀

---

**Savollar bolsa DEPLOYMENT_GUIDE.md ni o'qing!**

Hamma to'liq yo'riqnomalar bilan tayyorlangan! ✨
