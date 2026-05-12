#!/bin/bash
set -e

echo "=========================================="
echo "Docker Installation Script for EC2"
echo "=========================================="

# Update system
echo "1. Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install Docker
echo "2. Installing Docker..."
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Verify Docker installation
echo ""
echo "Docker version:"
docker --version

echo "Docker Compose version:"
docker compose version

# Install Docker Compose (legacy)
echo "3. Installing Docker Compose (legacy)..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Enable Docker service
echo "4. Enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

echo ""
echo "=========================================="
echo "Docker Installation Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Pull code: git clone <your-repo> /var/www/eshop"
echo "2. Build image: docker build -t eshop:latest ."
echo "3. Run container: docker-compose up -d"
echo "4. Check status: docker ps"
echo "=========================================="
