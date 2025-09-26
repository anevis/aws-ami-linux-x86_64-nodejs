# AWS AMI Linux x86_64 with Node.js

Create and publish an Amazon Machine Image (AMI) based on Amazon Linux 2023 x86_64 with the latest Node.js LTS for running Node.js web applications.

## 🚀 Features

- **Amazon Linux 2023 x86_64** - Latest stable Linux distribution from AWS
- **Node.js LTS** - Latest Long Term Support version of Node.js
- **Production Ready** - Pre-configured with PM2, Forever, and Nodemon
- **Web Server Ready** - Nginx configured as reverse proxy
- **Firewall Configured** - Ports 80, 443, 3000, and 8080 open
- **Sample Application** - Includes a sample Node.js app for testing
- **Systemd Integration** - Service templates for easy app deployment

## 📋 Prerequisites

- [Packer](https://www.packer.io/downloads) installed
- AWS CLI configured with appropriate credentials
- AWS account with EC2 permissions

## 🛠️ Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/anevis/aws-ami-linux-x86_64-nodejs.git
cd aws-ami-linux-x86_64-nodejs
```

### 2. Configure AWS credentials

```bash
aws configure
```

### 3. Build the AMI

```bash
./build.sh
```

## ⚙️ Customization

### Using Variables

Copy the example variables file and customize:

```bash
cp variables.pkrvars.hcl.example variables.pkrvars.hcl
```

Edit `variables.pkrvars.hcl`:

```hcl
region = "us-west-2"
instance_type = "t3.small"
ami_name = "my-custom-nodejs-ami-{{timestamp}}"
ami_description = "My custom Node.js AMI"
```

### Manual Build

```bash
# Initialize Packer
packer init aws-ami-nodejs.pkr.hcl

# Validate configuration
packer validate aws-ami-nodejs.pkr.hcl

# Build AMI
packer build aws-ami-nodejs.pkr.hcl
```

## 🎯 What's Included

### Software Components

- **Node.js LTS** - Latest Long Term Support version
- **npm** - Node Package Manager
- **PM2** - Production process manager
- **Forever** - Simple CLI tool for continuous running
- **Nodemon** - Development tool for auto-restarting
- **Nginx** - Web server and reverse proxy
- **Firewalld** - Firewall management

### Directory Structure

```
/opt/nodejs/              # Node.js applications directory  
/opt/nodejs/sample-app/   # Sample application
/etc/nginx/conf.d/        # Nginx configuration
/etc/systemd/system/      # Systemd service templates
```

### Helper Scripts

- `/usr/local/bin/nodejs-app-deploy` - Deploy Node.js applications

## 🚀 Using the AMI

### Launch Instance

```bash
aws ec2 run-instances \
  --image-id ami-xxxxxxxxx \
  --instance-type t3.micro \
  --key-name your-key-name \
  --security-group-ids sg-xxxxxxxxx
```

### Deploy Your Application

1. Upload your Node.js application to `/opt/nodejs/your-app/`
2. Use the helper script:

```bash
nodejs-app-deploy your-app /opt/nodejs/your-app
```

3. Your app will be available at `http://your-instance-ip/`

### Manual Service Management

```bash
# Start your application
sudo systemctl start nodejs-app@your-app

# Enable auto-start on boot
sudo systemctl enable nodejs-app@your-app

# Check status
sudo systemctl status nodejs-app@your-app
```

## 🏗️ Architecture

```
Internet → EC2 Security Group → Nginx (Port 80) → Node.js App (Port 3000)
```

- **Nginx** handles incoming HTTP requests on port 80
- **Reverse proxy** forwards requests to Node.js app on port 3000
- **Firewall** allows HTTP (80), HTTPS (443), and development ports (3000, 8080)
- **Systemd** manages Node.js application lifecycle

## 📁 File Structure

```
├── aws-ami-nodejs.pkr.hcl          # Main Packer configuration
├── build.sh                        # Build script
├── variables.pkrvars.hcl.example   # Variables template
├── scripts/
│   ├── install-nodejs.sh          # Node.js installation script
│   └── configure-system.sh        # System configuration script
└── README.md                       # This file
```

## 🔧 Troubleshooting

### Common Issues

1. **Packer not found**: Install Packer from [packer.io](https://www.packer.io/downloads)
2. **AWS credentials**: Run `aws configure` or set environment variables
3. **Permissions**: Ensure your AWS user has EC2 and IAM permissions
4. **Region**: Make sure your AWS CLI region matches the Packer configuration

### Logs

- Build logs: Check Packer output during build
- Instance logs: `/var/log/cloud-init-output.log`
- Application logs: `journalctl -u nodejs-app@your-app`

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the build
5. Submit a pull request

## 📞 Support

For questions and support, please open an issue in the GitHub repository.
