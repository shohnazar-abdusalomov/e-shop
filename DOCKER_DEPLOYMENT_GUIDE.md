# Docker Deployment Guide

## Overview

This guide covers deploying the E-SHOP application using Docker and Docker Compose on AWS EC2.

---

## Option 1: Traditional Deployment (No Docker)

See `DEPLOYMENT_GUIDE.md`

---

## Option 2: Docker Deployment

### Advantages of Docker

✅ Consistency across environments
✅ Easier scaling and load balancing
✅ Simplified dependency management
✅ Faster deployments
✅ Easy rollbacks

### Prerequisites

- AWS EC2 instance (Ubuntu 22.04)
- Docker installed
- Docker Compose installed

---

## Step 1: Install Docker

### 1.1 Automated Installation

```bash
# Upload install script to EC2
scp -i your-key.pem install-docker.sh ubuntu@your-ec2-ip:/tmp/

# SSH into instance
ssh -i your-key.pem ubuntu@your-ec2-ip

# Run installation script
chmod +x /tmp/install-docker.sh
/tmp/install-docker.sh
```

### 1.2 Manual Installation

```bash
# Update packages
sudo apt-get update
sudo apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Verify
docker --version
```

---

## Step 2: Clone Repository

```bash
# Create app directory
sudo mkdir -p /var/www/eshop
sudo chown -R $USER:$USER /var/www/eshop

# Clone repository
cd /var/www/eshop
git clone https://github.com/your-username/your-repo.git .
```

---

## Step 3: Build Docker Image

```bash
cd /var/www/eshop

# Build image
docker build -t eshop:latest .

# Verify image
docker images | grep eshop
```

---

## Step 4: Run with Docker Compose

### 4.1 Start Application

```bash
# From app directory
docker-compose up -d

# Check if running
docker ps
```

### 4.2 View Logs

```bash
# View all logs
docker-compose logs

# View specific service logs
docker-compose logs eshop

# Follow logs in real-time
docker-compose logs -f eshop
```

---

## Step 5: Access Application

### 5.1 Without Domain (using IP)

```
http://your-ec2-ip
```

### 5.2 With Domain

1. Update DNS records to point to EC2 IP
2. Wait for DNS propagation
3. Access via `https://your-domain.com`

---

## 🔧 Docker Commands

### Container Management

```bash
# Start containers
docker-compose up -d

# Stop containers
docker-compose down

# Restart containers
docker-compose restart

# Rebuild images
docker-compose build --no-cache

# View running containers
docker ps

# View all containers
docker ps -a
```

### Image Management

```bash
# List images
docker images

# Build image
docker build -t eshop:latest .

# Build without cache
docker build --no-cache -t eshop:latest .

# Remove image
docker rmi eshop:latest

# Tag image
docker tag eshop:latest eshop:v1.0
```

### Logs and Debugging

```bash
# View logs
docker logs container-id

# Follow logs
docker logs -f container-id

# View last 100 lines
docker logs --tail 100 container-id

# View docker-compose logs
docker-compose logs

# Follow docker-compose logs
docker-compose logs -f
```

### Container Inspection

```bash
# Get container stats
docker stats

# Inspect container
docker inspect container-id

# View container processes
docker top container-id

# Execute command in container
docker exec -it container-id /bin/sh
```

---

## 🚀 Deployment Workflow

### Initial Deployment

```bash
cd /var/www/eshop

# Clone code
git clone https://github.com/your-username/your-repo.git .

# Build image
docker build -t eshop:latest .

# Start containers
docker-compose up -d

# Check status
docker ps
```

### Update Deployment

```bash
cd /var/www/eshop

# Pull latest code
git pull origin main

# Rebuild image
docker build -t eshop:latest .

# Restart containers
docker-compose up -d

# Verify
docker ps
```

### Rollback

```bash
# Stop current container
docker-compose down

# Revert code
git revert HEAD
git push origin main

# Rebuild and restart
docker build -t eshop:latest .
docker-compose up -d
```

---

## 🔒 Production Setup with SSL

### Setup Reverse Proxy with Nginx (Docker)

Create `docker-compose.prod.yml`:

```yaml
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    container_name: eshop-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
      - ./ssl:/etc/letsencrypt
    networks:
      - eshop-network
    depends_on:
      - eshop

  eshop:
    build: .
    container_name: eshop-app
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    networks:
      - eshop-network
    restart: unless-stopped

networks:
  eshop-network:
    driver: bridge
```

Run with:
```bash
docker-compose -f docker-compose.prod.yml up -d
```

---

## 📊 Monitoring

### View Resource Usage

```bash
# Real-time stats
docker stats

# Specific container
docker stats container-id
```

### Check Logs for Errors

```bash
# View error logs
docker-compose logs --tail 50 | grep -i error

# Follow logs
docker-compose logs -f
```

### Health Checks

```bash
# Check container health
docker ps --format "table {{.Names}}\t{{.Status}}"

# Get detailed info
docker inspect eshop | grep -A 5 "Health"
```

---

## 🐛 Troubleshooting

### Container won't start

```bash
# Check logs
docker-compose logs eshop

# Check image
docker images | grep eshop

# Rebuild image
docker-compose build --no-cache
```

### Port already in use

```bash
# Find what's using port
sudo lsof -i :80
sudo lsof -i :443

# Stop all containers
docker-compose down

# Remove unused containers
docker container prune
```

### Out of memory

```bash
# Check disk space
docker system df

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune

# Clean up everything
docker system prune -a
```

### DNS resolution issues

```bash
# Check network
docker network ls

# Inspect network
docker network inspect eshop-network

# Restart containers
docker-compose restart
```

---

## 📦 Database Setup (Optional)

### With MongoDB

Uncomment in `docker-compose.yml`:

```yaml
  mongodb:
    image: mongo:6.0
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: password123
    ports:
      - "27017:27017"
    volumes:
      - mongo-data:/data/db
```

Then:
```bash
# Start with database
docker-compose up -d

# Connect to MongoDB
docker exec -it eshop-db mongosh -u root -p password123
```

---

## 🔄 CI/CD with Docker

### GitHub Actions Example

```yaml
name: Build and Deploy with Docker

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: SSH and Deploy
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.HOST }}
          username: ubuntu
          key: ${{ secrets.SSH_KEY }}
          script: |
            cd /var/www/eshop
            git pull origin main
            docker build -t eshop:latest .
            docker-compose up -d
            docker image prune -af
```

---

## 📋 Docker Compose Reference

### Start/Stop

```bash
docker-compose up              # Start services
docker-compose up -d           # Start in detached mode
docker-compose down            # Stop and remove containers
docker-compose down -v         # Stop and remove volumes
```

### Build/Update

```bash
docker-compose build           # Build images
docker-compose build --no-cache # Build without cache
docker-compose pull            # Pull images
```

### Execute

```bash
docker-compose exec service cmd           # Run command
docker-compose run service cmd            # Run one-off command
```

---

## ✅ Verification Checklist

- [ ] Docker installed: `docker --version`
- [ ] Docker Compose installed: `docker-compose --version`
- [ ] Repository cloned
- [ ] Dockerfile exists
- [ ] docker-compose.yml exists
- [ ] Image built successfully: `docker images`
- [ ] Container running: `docker ps`
- [ ] App accessible on localhost
- [ ] Logs show no errors: `docker-compose logs`
- [ ] DNS configured (if using domain)
- [ ] SSL certificate setup (if using HTTPS)

---

## 🎯 Next Steps

1. **Scale application** - Use load balancer
2. **Set up monitoring** - Use Prometheus/Grafana
3. **Backup strategy** - Regular container backups
4. **Update strategy** - Blue-green deployments
5. **Security** - Scan images, manage secrets

---

**Happy Docker deploying! 🐳**
