#!/bin/bash
set -e

echo "Starting Node.js installation..."

# Update the system
sudo dnf update -y

# Install required packages
sudo dnf install -y curl wget tar gzip

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

# Install commonly used global packages for web development
sudo npm install -g pm2 forever nodemon

# Create a directory for Node.js applications
sudo mkdir -p /opt/nodejs
sudo chown ec2-user:ec2-user /opt/nodejs

echo "Node.js installation completed successfully!"