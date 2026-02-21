#!/bin/bash
set -e
PASS=$1

# 1. Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
echo "$PASS" | sudo tailscale up --ssh

# 2. Harden SSH Configuration
# Use sed to find and replace (or append) the settings
echo "$PASS" | sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
echo "$PASS" | sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config

adduser adi
usermod -aG sudo adi
su - adi
echo "$PASS" | sudo systemctl restart ssh
systemctl is-active ssh.socket
echo "$PASS" | sudo systemctl stop ssh.socket
echo "$PASS" | sudo systemctl disable ssh.socket

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
. ~/.bashrc
nvm install --lts
npm i -g openclaw@latest
openclaw onboard --install-daemon