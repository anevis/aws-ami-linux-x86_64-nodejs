#!/bin/bash
set -e

echo "🚀 Building AWS AMI with Node.js..."

# Check if packer is installed
if ! command -v packer &> /dev/null; then
    echo "❌ Packer is not installed. Please install Packer first."
    echo "Visit: https://www.packer.io/downloads"
    exit 1
fi

# Check if AWS credentials are configured
if [ -z "$AWS_ACCESS_KEY_ID" ] && [ ! -f ~/.aws/credentials ]; then
    echo "❌ AWS credentials not found. Please configure AWS credentials first."
    echo "Run: aws configure"
    exit 1
fi

# Initialize packer
echo "📦 Initializing Packer..."
packer init aws-ami-nodejs.pkr.hcl

# Validate the configuration
echo "✅ Validating Packer configuration..."
if [ -f "variables.pkrvars.hcl" ]; then
    packer validate -var-file="variables.pkrvars.hcl" aws-ami-nodejs.pkr.hcl
else
    packer validate aws-ami-nodejs.pkr.hcl
fi

# Build the AMI
echo "🏗️ Building AMI..."
if [ -f "variables.pkrvars.hcl" ]; then
    packer build -var-file="variables.pkrvars.hcl" aws-ami-nodejs.pkr.hcl
else
    packer build aws-ami-nodejs.pkr.hcl
fi

echo "✅ AMI build completed successfully!"

if [ -f "manifest.json" ]; then
    AMI_ID=$(jq -r '.builds[0].artifact_id' manifest.json | cut -d':' -f2)
    REGION=$(jq -r '.builds[0].custom_data.region // "us-east-1"' manifest.json)
    echo "🎉 AMI created successfully!"
    echo "AMI ID: $AMI_ID"
    echo "Region: $REGION"
    echo ""
    echo "To launch an instance with this AMI:"
    echo "aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --key-name YOUR_KEY_NAME --security-group-ids YOUR_SECURITY_GROUP"
fi