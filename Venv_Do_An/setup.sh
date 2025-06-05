#!/bin/bash

set -e

echo "👉 Updating system and installing prerequisites..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release software-properties-common

### --------------------------
### CÀI ĐẶT DOCKER
### --------------------------

echo "👉 Adding Docker's official GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "👉 Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "👉 Updating apt package list..."
sudo apt-get update

echo "👉 Available Docker versions:"
apt-cache madison docker-ce | awk '{ print $3 }'

# 👉 Thay đổi phiên bản Docker tại đây nếu muốn
VERSION_STRING="5:27.3.1-1~ubuntu.22.04~jammy"

echo "👉 Installing Docker version $VERSION_STRING..."
sudo apt-get install -y docker-ce=$VERSION_STRING docker-ce-cli=$VERSION_STRING containerd.io docker-buildx-plugin docker-compose-plugin

echo "👉 Installing Docker Compose binary..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.15.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "✅ Docker version: $(docker --version)"
echo "✅ Docker Compose version: $(docker-compose --version)"

### --------------------------
### CÀI ĐẶT MONGODB
### --------------------------

echo "👉 Importing MongoDB public GPG key..."
curl -fsSL https://pgp.mongodb.com/server-7.0.asc | \
  sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor

echo "👉 Creating MongoDB source list..."
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/7.0 multiverse" | \
  sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

echo "👉 Updating apt package list..."
sudo apt-get update

echo "👉 Installing MongoDB..."
sudo apt-get install -y mongodb-org

echo "👉 Enabling and starting MongoDB service..."
sudo systemctl enable mongod
sudo systemctl start mongod

echo "✅ MongoDB version:"
mongod --version | head -n 1

### --------------------------
### CÀI ĐẶT NVM & NODE 14
### --------------------------

echo "👉 Installing NVM (Node Version Manager)..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC1090
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo "👉 Installing Node.js v14 via NVM..."
nvm install 14
nvm use 14
nvm alias default 14

echo "✅ Node.js version: $(node -v)"
echo "✅ NPM version: $(npm -v)"

echo "🎉 All installations completed successfully: Docker, Docker Compose, MongoDB, Node.js v14!"

