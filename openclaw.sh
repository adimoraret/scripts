#!/bin/bash
set -e
PASS=$1

# 1. Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
echo "$PASS" | sudo tailscale up --ssh

# 2. Harden SSH Configuration
# Use sed to find and replace (or append) the settings
read -rp "Enter tailscale ListenAddress IP: " SSH_IP

if grep -qE '^#?ListenAddress\s+' /etc/ssh/sshd_config; then
	echo "$PASS" | sudo sed -i "s/^#\?ListenAddress.*/ListenAddress ${SSH_IP}/" /etc/ssh/sshd_config
else
	echo "ListenAddress ${SSH_IP}" | sudo tee -a /etc/ssh/sshd_config >/dev/null
fi

echo "$PASS" | sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
echo "$PASS" | sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config

adduser adi
usermod -aG sudo adi
echo "$PASS" | sudo systemctl restart ssh
systemctl is-active ssh.socket
echo "$PASS" | sudo systemctl stop ssh.socket
echo "$PASS" | sudo systemctl disable ssh.socket

sudo -u adi -H bash -lc 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash'
sudo -u adi -H bash -lc 'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && nvm install --lts && npm i -g openclaw@latest'