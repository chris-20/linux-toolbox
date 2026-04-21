#!/bin/bash
set -e

echo "🔄 Update läuft..."
apt update -y

echo "📦 Installiere Basis-Pakete..."
apt install -y curl net-tools git fail2ban wget ca-certificates nano zstd gnupg

echo "🔐 Aktiviere Root SSH Login..."
if grep -q "PermitRootLogin" /etc/ssh/sshd_config; then
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
else
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
fi

echo "🔁 Starte SSH neu..."
systemctl restart ssh

echo "🐳 Installiere Docker (offizielles Repository)..."

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

echo "🔄 Update Paketlisten (Docker Repo)..."
apt update -y

echo "📦 Installiere Docker Engine..."
apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

echo "🚀 Aktiviere Docker Service..."
systemctl enable docker
systemctl start docker

echo "🌐 Hole IP..."
IP=$(hostname -I | awk '{print $1}')

echo ""
echo "=============================="
echo "✅ Fertig!"
echo "🌍 IP: $IP"
echo "🔑 ssh root@$IP"
echo "🐳 Docker ist installiert"
echo "=============================="
