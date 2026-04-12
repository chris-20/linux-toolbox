#!/bin/bash
set -e

echo "🔄 Update & Installation..."
apt update -y
apt install -y curl net-tools unattended-upgrades apt-listchanges

echo "🔐 Aktiviere automatische Sicherheitsupdates..."
dpkg-reconfigure -f noninteractive unattended-upgrades

echo "⚙️ Konfiguriere SSH (Root Login aktivieren)..."
if grep -q "PermitRootLogin" /etc/ssh/sshd_config; then
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
else
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
fi

systemctl restart ssh

echo "🌐 Ermittle Server-IP..."
IP=$(hostname -I | awk '{print $1}')

echo ""
echo "=============================="
echo "✅ Setup abgeschlossen!"
echo "🌍 Server-IP: $IP"
echo "🔑 SSH: root@$IP"
echo "=============================="
