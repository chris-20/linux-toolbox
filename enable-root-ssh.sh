#!/bin/bash
set -e

echo "🔄 Update läuft..."
apt update -y

echo "📦 Installiere Pakete..."
apt install -y curl net-tools git fail2ban wget ca-certificates nano zstd

echo "🔐 Aktiviere Root SSH Login..."
if grep -q "PermitRootLogin" /etc/ssh/sshd_config; then
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
else
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
fi

echo "🔁 Starte SSH neu..."
systemctl restart ssh

echo "🌐 Hole IP..."
IP=$(hostname -I | awk '{print $1}')

echo ""
echo "=============================="
echo "✅ Fertig!"
echo "🌍 IP: $IP"
echo "🔑 ssh root@$IP"
echo "=============================="
