#!/bin/bash
set -e

echo "🔄 System Update..."
apt update -y

echo "📦 Installiere Basis-Pakete..."
apt install -y curl net-tools git fail2ban wget ca-certificates nano zstd gnupg

echo "🔐 SSH Root Login aktivieren..."
if grep -q "PermitRootLogin" /etc/ssh/sshd_config; then
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
else
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
fi

echo "🔁 SSH Neustart..."
systemctl restart ssh

echo "🐳 Docker Repository einrichten..."

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

echo "🔄 Paketlisten aktualisieren..."
apt update -y

echo "📦 Installiere Docker Engine..."
apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

echo "🚀 Docker aktivieren..."
systemctl enable docker
systemctl restart docker

sleep 3

echo "👤 Docker Zugriff vorbereiten..."
usermod -aG docker $USER || true

echo "📦 Dockhand vorbereiten..."

# Volume sicherstellen
docker volume create dockhand_data || true

# 🔥 WICHTIG: alten Container sauber entfernen (fix für dein Problem)
docker rm -f dockhand 2>/dev/null || true

echo "🧠 Starte Dockhand..."
docker run -d \
  --name dockhand \
  --restart unless-stopped \
  -p 3000:3000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v dockhand_data:/app/data \
  fnsys/dockhand:latest

echo "🌐 IP ermitteln..."
IP=$(hostname -I | awk '{print $1}')

echo ""
echo "=============================="
echo "✅ SETUP ABGESCHLOSSEN"
echo "=============================="
echo "🌍 Server IP: $IP"
echo "🧠 Dockhand UI: http://$IP:3000"
echo "🐳 Docker Socket: verbunden"
echo "🔁 Auto-Restart: aktiv"
echo "=============================="
echo "🔑 SSH: ssh root@$IP"
echo "=============================="
