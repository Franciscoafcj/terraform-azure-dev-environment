#!/bin/bash
# -----------------------------------------------------------------------------
# Cloud-Init User Data Script
# Provisions development tools on Ubuntu 24.04 LTS
# -----------------------------------------------------------------------------
set -euxo pipefail
exec > >(tee /var/log/user-data.log) 2>&1

export DEBIAN_FRONTEND=noninteractive

echo "========================================="
echo "Starting VM provisioning..."
echo "========================================="

# ---------------------------------------------------------
# 1. System Update & Essential Packages
# ---------------------------------------------------------
echo ">>> Updating system packages..."
apt-get update -y
apt-get upgrade -y

echo ">>> Installing essential packages..."
apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  unzip \
  wget \
  jq \
  htop \
  tree \
  make \
  build-essential \
  software-properties-common

# ---------------------------------------------------------
# 2. Docker Installation (Official Repository)
# ---------------------------------------------------------
echo ">>> Installing Docker..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker

# Add admin user to docker group
usermod -aG docker ${admin_username}

# ---------------------------------------------------------
# 3. Docker Compose v2 Plugin (Latest from GitHub)
# ---------------------------------------------------------
echo ">>> Installing Docker Compose v2..."
COMPOSE_VERSION=$$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.tag_name')
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL "https://github.com/docker/compose/releases/download/$${COMPOSE_VERSION}/docker-compose-linux-$(uname -m)" \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

echo "Docker Compose version: $$(docker compose version)"

# ---------------------------------------------------------
# 4. Node.js 20 LTS (via NodeSource)
# ---------------------------------------------------------
echo ">>> Installing Node.js 20 LTS..."
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

echo "Node.js version: $$(node --version)"
echo "npm version: $$(npm --version)"

# ---------------------------------------------------------
# 5. Python 3, pip, and venv
# ---------------------------------------------------------
echo ">>> Installing Python 3, pip, and venv..."
apt-get install -y python3 python3-pip python3-venv

echo "Python version: $$(python3 --version)"

# ---------------------------------------------------------
# 6. Go 1.22.4
# ---------------------------------------------------------
echo ">>> Installing Go 1.22.4..."
GO_VERSION="1.22.4"
curl -fsSL "https://go.dev/dl/go$${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tar.gz
rm -rf /usr/local/go
tar -C /usr/local -xzf /tmp/go.tar.gz
rm /tmp/go.tar.gz

# Set Go environment variables system-wide
cat >> /etc/profile.d/go.sh <<'GOEOF'
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH
GOEOF
chmod +x /etc/profile.d/go.sh

echo "Go version: $$(/usr/local/go/bin/go version)"

# ---------------------------------------------------------
# 7. Terraform (HashiCorp APT Repository)
# ---------------------------------------------------------
echo ">>> Installing Terraform..."
curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo \
  "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com \
  $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list > /dev/null

apt-get update -y
apt-get install -y terraform

echo "Terraform version: $$(terraform --version)"

# ---------------------------------------------------------
# 8. Azure CLI
# ---------------------------------------------------------
echo ">>> Installing Azure CLI..."
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

echo "Azure CLI version: $$(az --version | head -1)"

# ---------------------------------------------------------
# 9. VS Code Server (code-server)
# ---------------------------------------------------------
echo ">>> Installing VS Code Server (code-server)..."
curl -fsSL https://code-server.dev/install.sh | sh

# Generate a random password for code-server
CODE_SERVER_PASSWORD=$$(openssl rand -base64 16)

# Create code-server configuration directory
mkdir -p /home/${admin_username}/.config/code-server

# Create code-server config file
cat > /home/${admin_username}/.config/code-server/config.yaml <<EOF
bind-addr: 0.0.0.0:8080
auth: password
password: $${CODE_SERVER_PASSWORD}
cert: false
EOF

# Create systemd service for code-server
cat > /etc/systemd/system/code-server@.service <<'SVCEOF'
[Unit]
Description=code-server for %i
After=network.target

[Service]
Type=exec
User=%i
ExecStart=/usr/bin/code-server --config /home/%i/.config/code-server/config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
SVCEOF

# Enable and start code-server for the admin user
systemctl daemon-reload
systemctl enable code-server@${admin_username}
systemctl start code-server@${admin_username}

echo "VS Code Server password: $${CODE_SERVER_PASSWORD}"

# ---------------------------------------------------------
# 10. Git Configuration
# ---------------------------------------------------------
echo ">>> Configuring Git for ${admin_username}..."
sudo -u ${admin_username} git config --global user.name "${git_user_name}"
sudo -u ${admin_username} git config --global user.email "${git_user_email}"
sudo -u ${admin_username} git config --global init.defaultBranch main

# ---------------------------------------------------------
# 11. Workspace Directory
# ---------------------------------------------------------
echo ">>> Creating workspace directory..."
mkdir -p /home/${admin_username}/workspace

# ---------------------------------------------------------
# 12. Fix Ownership
# ---------------------------------------------------------
echo ">>> Setting proper file ownership..."
chown -R ${admin_username}:${admin_username} /home/${admin_username}

# ---------------------------------------------------------
# Done
# ---------------------------------------------------------
echo "========================================="
echo "VM provisioning complete!"
echo "========================================="
echo ""
echo "VS Code Server is available at:"
echo "  URL:      http://<PUBLIC_IP>:8080"
echo "  Password: $${CODE_SERVER_PASSWORD}"
echo ""
echo "Connect via SSH:"
echo "  ssh ${admin_username}@<PUBLIC_IP>"
echo ""
echo "========================================="
