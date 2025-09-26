packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ami_name" {
  type    = string
  default = "aws-ami-linux-x86_64-nodejs-{{timestamp}}"
}

variable "ami_description" {
  type    = string
  default = "Amazon Linux 2023 x86_64 with Node.js LTS for web applications"
}

source "amazon-ebs" "nodejs-ami" {
  ami_name      = var.ami_name
  ami_description = var.ami_description
  instance_type = var.instance_type
  region        = var.region
  
  source_ami_filter {
    filters = {
      name                = "al2023-ami-*-x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  
  ssh_username = "ec2-user"
  
  tags = {
    Name        = "AWS AMI Linux x86_64 with Node.js"
    Environment = "production"
    OS          = "Amazon Linux 2023"
    Architecture = "x86_64"
    NodeJS      = "LTS"
    Purpose     = "Web Application Server"
  }
}

build {
  name = "nodejs-ami"
  sources = [
    "source.amazon-ebs.nodejs-ami"
  ]

  provisioner "shell" {
    script = "./scripts/install-nodejs.sh"
  }

  provisioner "shell" {
    script = "./scripts/configure-system.sh"
  }

  post-processor "manifest" {
    output = "manifest.json"
    strip_path = true
  }
}