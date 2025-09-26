#!/bin/bash
set -e

echo "Starting Node.js installation..."

# Update the system
sudo dnf update -y

# Install required packages
sudo dnf install -y curl wget tar gzip unzip

# Install Node.js using NodeSource repository (gets latest LTS)
curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -

# Install Node.js
sudo dnf install -y nodejs

# Verify installation
node_version=$(node --version)
npm_version=$(npm --version)

echo "Node.js installed successfully!"
echo "Node.js version: $node_version"
echo "npm version: $npm_version"

# Install AWS CLI v2
echo "Installing AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws/

# Verify AWS CLI installation
aws_version=$(aws --version)
echo "AWS CLI installed successfully: $aws_version"

# Install commonly used global packages for web development
sudo npm install -g pm2 forever nodemon

# Create a directory for Node.js applications
sudo mkdir -p /opt/nodejs
sudo chown ec2-user:ec2-user /opt/nodejs

echo "Node.js installation completed successfully!"