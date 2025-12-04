#!/bin/bash
clear
echo "🚀 Hospedagem Completa TV Box - macbservices v3.0 (PHP + Cloudflare AUTO)"
echo "Ubuntu 18.04 RK322x - 1 Comando Total!"
sleep 2

# DNS Fix (obrigatório pro TV Box)
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf

# Apache + PHP7.4 Completo
apt update && apt upgrade -y -qq
apt install -y apache2 php7.4 libapache2-mod-php7.4 php7.4-curl php7.4-gd php7.4-mbstring php7.4-xml wget curl

# PHP Handler (corrige código na tela)
cat > /etc/apache2/conf-available/php-handler.conf << 'EOF'
<FilesMatch \.php$>
    SetHandler application/x-httpd-php
</FilesMatch>
<FilesMatch \.phps$>
    SetHandler application/x-httpd-php-source
</FilesMatch>
EOF

a2enmod php7.4 rewrite
systemctl restart apache2

# Teste PHP
echo "<?php phpinfo(); ?>" > /var/www/html/info.php
chown -R www-data:www-data /var/www/html

echo "✅ Apache + PHP OK! http://$(hostname -I | awk '{print $1}')/info.php"

# Cloudflare Tunnel AUTOMÁTICO (igual projeto HTML)
echo "🔐 Cloudflare Tunnel AUTOMÁTICO (3min)..."
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O /usr/local/bin/cloudflared
chmod +x /usr/local/bin/cloudflared

read -p "DOMÍNIO (ex: seunovo.grythprogress.com.br): " DOMINIO
read -p "NOME TÚNEL (ex: macb-site): " NOME_TUNEL

# AUTOMÁTICO: Login → Credenciais → Tunnel → Config → DNS → Service
cloudflared tunnel login
sleep 10
ARQUIVO_CREDENCIAIS=$(ls ~/.cloudflared/*.json | head -1)

cloudflared tunnel create $NOME_TUNEL
TUNNEL_UUID=$(cloudflared tunnel list | grep $NOME_TUNEL | awk '{print $1}')

cat > ~/.cloudflared/config.yml << EOF
tunnel: $NOME_TUNEL
credentials-file: $ARQUIVO_CREDENCIAIS
ingress:
  - hostname: $DOMINIO
    service: http://localhost:80
  - service: http_status:404
EOF

cloudflared tunnel route dns $NOME_TUNEL $DOMINIO
cloudflared service install
systemctl enable --now cloudflared

echo "🎉 SITE 100% ONLINE: https://$DOMINIO"
echo "📤 Baixe Google Drive → /var/www/html/"
echo "📊 Logs: journalctl -u cloudflared -f"
