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

PTERODACTYL_DIRECTORY="/var/www/pterodactyl"

step() {
echo -e "\e[1;34m[➤] $1\e[0m"
}

success() {
echo -e "\e[1;32m[✔] $1\e[0m"
}

error() {
echo -e "\e[1;31m[✘] $1\e[0m"
}

if [ "$EUID" -ne 0 ]; then
error "Please run as root."
exit 1
fi

step "Checking Pterodactyl installation..."

if [ ! -d "$PTERODACTYL_DIRECTORY" ]; then
error "Pterodactyl not found at $PTERODACTYL_DIRECTORY"
exit 1
fi

cd "$PTERODACTYL_DIRECTORY" || exit 1

step "Updating packages..."
apt update -y

step "Installing dependencies..."
apt install -y curl wget unzip zip git ca-certificates gnupg

step "Downloading Blueprint Framework..."
wget -O release.zip https://github.com/BlueprintFramework/framework/releases/latest/download/release.zip

step "Extracting Blueprint..."
unzip -o release.zip

step "Installing Node.js..."

mkdir -p /etc/apt/keyrings

curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | 
gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" > /etc/apt/sources.list.d/nodesource.list

apt update -y
apt install -y nodejs

step "Installing Yarn..."
npm install -g yarn

step "Installing panel dependencies..."
yarn install --network-timeout 100000

step "Creating Blueprint configuration..."

cat > .blueprintrc << EOF
WEBUSER="www-data";
OWNERSHIP="www-data:www-data";
USERSHELL="/bin/bash";
EOF

step "Running Blueprint installer..."

chmod +x ./blueprint.sh
./blueprint.sh

step "Downloading Dyrox Addons..."
wget -O Addons.zip https://github.com/DyroxCloud/blueprint/raw/main/Addons.zip

step "Extracting Addons..."
unzip -o Addons.zip

step "Installing Addons..."
blueprint -install *.blueprint

step "Cleaning temporary files..."
rm -f release.zip Addons.zip

echo
echo -e "\e[1;32m"
echo "================================================="
echo "        ✅ INSTALLATION COMPLETED"
echo "           ☁️ DYROX CLOUD ☁️"
echo "================================================="
echo -e "\e[0m"
