#!/bin/bash

# ==================================

# ☁️ DYROX CLOUD INSTALLER ☁️

# ==================================

clear

echo -e "\e[1;36m"
echo "================================================="
echo "          🚀 DYROX CLOUD INSTALLER 🚀"
echo "================================================="
echo "      Blueprint Framework + Dyrox Addons"
echo "================================================="
echo -e "\e[0m"

export PTERODACTYL_DIRECTORY=/var/www/pterodactyl

step() {
echo -e "\e[1;34m[➤] $1\e[0m"
}

success() {
echo -e "\e[1;32m[✔] $1\e[0m"
}

error() {
echo -e "\e[1;31m[✘] $1\e[0m"
}

# Check Root

if [ "$EUID" -ne 0 ]; then
error "Please run this script as root."
exit 1
fi

# Update System

step "Updating package lists..."
apt update -y

# Install Dependencies

step "Installing dependencies..."
apt install -y curl wget unzip zip git ca-certificates gnupg

# Check Panel Directory

step "Checking Pterodactyl installation..."
if [ ! -d "$PTERODACTYL_DIRECTORY" ]; then
error "Pterodactyl directory not found!"
exit 1
fi

cd $PTERODACTYL_DIRECTORY

# Download Blueprint Framework

step "Downloading Blueprint Framework..."
wget https://github.com/BlueprintFramework/framework/releases/latest/download/release.zip -O release.zip

step "Extracting Blueprint..."
unzip -o release.zip

# Install Node.js 22

step "Setting up Node.js repository..."
mkdir -p /etc/apt/keyrings

curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key 
| gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" \

> /etc/apt/sources.list.d/nodesource.list

apt update -y

step "Installing Node.js..."
apt install -y nodejs

# Install Yarn

step "Installing Yarn..."
npm install -g yarn

# Install Node Modules

step "Installing panel dependencies..."
yarn install --network-timeout 100000

# Configure Blueprint

step "Configuring Blueprint..."

cat > $PTERODACTYL_DIRECTORY/.blueprintrc << EOF
WEBUSER="www-data";
OWNERSHIP="www-data:www-data";
USERSHELL="/bin/bash";
EOF

# Run Blueprint Setup

step "Running Blueprint setup..."

chmod +x blueprint.sh
bash blueprint.sh

# Download Dyrox Addons

step "Downloading Dyrox Cloud Addons..."

wget https://github.com/dyroxcloud/blueprint/raw/main/Addons.zip -O Addons.zip

# Extract Addons

step "Extracting Addons..."
unzip -o Addons.zip

# Install Addons

step "Installing Blueprint Addons..."
blueprint -install *.blueprint

# Cleanup

step "Cleaning temporary files..."
rm -f release.zip
rm -f Addons.zip

# Finish

echo
echo -e "\e[1;32m"
echo "================================================="
echo "        ✅ INSTALLATION COMPLETED"
echo "           ☁️ DYROX CLOUD ☁️"
echo "================================================="
echo " Blueprint Framework Installed Successfully"
echo " Dyrox Cloud Addons Installed Successfully"
echo "================================================="
echo -e "\e[0m"
