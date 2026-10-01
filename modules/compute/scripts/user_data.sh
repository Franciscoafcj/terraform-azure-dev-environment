#!/bin/bash
# Terraform template: only the three input placeholders below are interpolated.
set -euo pipefail
umask 077
exec > >(tee -a /var/log/user-data.log) 2>&1
trap 'echo "Provisioning failed at line $LINENO" >&2' ERR
export DEBIAN_FRONTEND=noninteractive

ADMIN_USER="${admin_username}"
GIT_NAME=$(printf '%s' '${git_user_name_b64}' | base64 --decode)
GIT_EMAIL=$(printf '%s' '${git_user_email_b64}' | base64 --decode)
USER_DIR="/home/$ADMIN_USER"

apt-get -o Acquire::Retries=3 update
apt-get -o Acquire::Retries=3 install -y ca-certificates curl gnupg lsb-release \
  unzip jq htop tree make build-essential git openssl python3 python3-pip \
  python3-venv golang-go

install -m 0755 -d /etc/apt/keyrings
curl --fail --show-error --silent --retry 3 https://download.docker.com/linux/ubuntu/gpg \
  | gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg
chmod 644 /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt-get -o Acquire::Retries=3 update
apt-get -o Acquire::Retries=3 install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker
usermod -aG docker "$ADMIN_USER"

# Download installers to disk so HTTP failures are detected before execution.
curl --fail --show-error --silent --retry 3 https://deb.nodesource.com/setup_24.x -o /tmp/nodesource-setup.sh
bash /tmp/nodesource-setup.sh
apt-get -o Acquire::Retries=3 install -y nodejs

curl --fail --show-error --silent --retry 3 https://apt.releases.hashicorp.com/gpg \
  | gpg --batch --yes --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
chmod 644 /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list
apt-get -o Acquire::Retries=3 update
apt-get -o Acquire::Retries=3 install -y terraform

curl --fail --show-error --silent --location --retry 3 https://aka.ms/InstallAzureCLIDeb -o /tmp/azure-cli-install.sh
bash /tmp/azure-cli-install.sh
curl --fail --show-error --silent --retry 3 https://code-server.dev/install.sh -o /tmp/code-server-install.sh
sh /tmp/code-server-install.sh

install -d -m 700 -o "$ADMIN_USER" -g "$ADMIN_USER" "$USER_DIR/.config" "$USER_DIR/.config/code-server"
# Keep the existing password when re-running provisioning.
CONFIG="$USER_DIR/.config/code-server/config.yaml"
if [ ! -f "$CONFIG" ]; then
  CODE_SERVER_PASSWORD=$(openssl rand -base64 24)
  cat > "$CONFIG" <<EOF
bind-addr: 127.0.0.1:8080
auth: password
password: $CODE_SERVER_PASSWORD
cert: false
EOF
  unset CODE_SERVER_PASSWORD
else
  sed -i 's/^bind-addr:.*/bind-addr: 127.0.0.1:8080/' "$CONFIG"
fi
chown "$ADMIN_USER:$ADMIN_USER" "$CONFIG"
chmod 600 "$CONFIG"

cat > /etc/systemd/system/code-server@.service <<'EOF'
[Unit]
Description=code-server for %i
After=network.target

[Service]
Type=exec
User=%i
WorkingDirectory=/home/%i
ExecStart=/usr/bin/code-server --config /home/%i/.config/code-server/config.yaml
Restart=on-failure
RestartSec=5
UMask=0077

[Install]
WantedBy=multi-user.target
EOF
chmod 644 /etc/systemd/system/code-server@.service
systemctl daemon-reload
systemctl enable "code-server@$ADMIN_USER"
systemctl restart "code-server@$ADMIN_USER"

sudo -H -u "$ADMIN_USER" git config --global user.name "$GIT_NAME"
sudo -H -u "$ADMIN_USER" git config --global user.email "$GIT_EMAIL"
sudo -H -u "$ADMIN_USER" git config --global init.defaultBranch main
install -d -m 755 -o "$ADMIN_USER" -g "$ADMIN_USER" "$USER_DIR/workspace"

docker compose version
node --version
go version
terraform version
systemctl is-active "code-server@$ADMIN_USER"
echo "Provisioning complete. Access code-server through an SSH tunnel."
