#!/bin/bash
set -e

echo "Configuring system for Node.js web applications..."

# Configure firewall for common web ports
sudo dnf install -y firewalld
sudo systemctl enable firewalld
sudo systemctl start firewalld

# Allow HTTP and HTTPS traffic
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload

# Install and configure nginx as reverse proxy
sudo dnf install -y nginx
sudo systemctl enable nginx

# Create basic nginx configuration for Node.js proxy
sudo tee /etc/nginx/conf.d/nodejs.conf > /dev/null <<EOF
server {
    listen 80;
    server_name _;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Create systemd service template for Node.js applications
sudo tee /etc/systemd/system/nodejs-app@.service > /dev/null <<EOF
[Unit]
Description=Node.js App (%i)
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/nodejs/%i
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=5
Environment=NODE_ENV=production
Environment=PORT=3000

[Install]
WantedBy=multi-user.target
EOF

# Create a sample Node.js application
sudo mkdir -p /opt/nodejs/sample-app
sudo tee /opt/nodejs/sample-app/server.js > /dev/null <<EOF
const http = require('http');
const port = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end(\`
    <!DOCTYPE html>
    <html>
    <head>
        <title>Node.js AMI</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; }
            .container { max-width: 600px; margin: 0 auto; text-align: center; }
            .success { color: green; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1 class="success">🚀 Node.js AMI is Working!</h1>
            <p>This is a sample Node.js application running on Amazon Linux 2023.</p>
            <p><strong>Node.js Version:</strong> \${process.version}</p>
            <p><strong>Architecture:</strong> \${process.arch}</p>
            <p><strong>Platform:</strong> \${process.platform}</p>
            <p><strong>Uptime:</strong> \${Math.floor(process.uptime())} seconds</p>
        </div>
    </body>
    </html>
    \`);
});

server.listen(port, () => {
    console.log(\`Server running at http://localhost:\${port}/\`);
});
EOF

sudo tee /opt/nodejs/sample-app/package.json > /dev/null <<EOF
{
  "name": "sample-nodejs-app",
  "version": "1.0.0",
  "description": "Sample Node.js application for AWS AMI",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "author": "AWS AMI Builder",
  "license": "MIT"
}
EOF

# Set proper ownership
sudo chown -R ec2-user:ec2-user /opt/nodejs

# Create a helper script for users
sudo tee /usr/local/bin/nodejs-app-deploy > /dev/null <<'EOF'
#!/bin/bash
# Helper script to deploy Node.js applications

APP_NAME="$1"
APP_PATH="$2"

if [ -z "$APP_NAME" ] || [ -z "$APP_PATH" ]; then
    echo "Usage: nodejs-app-deploy <app-name> <app-path>"
    echo "Example: nodejs-app-deploy myapp /opt/nodejs/myapp"
    exit 1
fi

echo "Deploying Node.js application: $APP_NAME"
echo "Application path: $APP_PATH"

# Install dependencies if package.json exists
if [ -f "$APP_PATH/package.json" ]; then
    cd "$APP_PATH"
    npm install --production
fi

# Enable and start the service
sudo systemctl enable "nodejs-app@$APP_NAME"
sudo systemctl start "nodejs-app@$APP_NAME"
sudo systemctl status "nodejs-app@$APP_NAME"

echo "Application $APP_NAME deployed successfully!"
echo "You can manage it with: sudo systemctl [start|stop|restart|status] nodejs-app@$APP_NAME"
EOF

sudo chmod +x /usr/local/bin/nodejs-app-deploy

# Clean up package cache
sudo dnf clean all

echo "System configuration completed successfully!"