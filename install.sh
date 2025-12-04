#!/bin/bash
clear
echo "🚀 Hospedagem Site TV Box - macbservices v3.0 (Apache + PHP7.4 + Cloudflare)"
echo "Otimizado para arquivos do Google Drive - Ubuntu 18.04 RK322x"
sleep 2

# Fix DNS primeiro (problema comum no TV Box)
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf

apt update && apt upgrade -y -qq
apt install -y apache2 php7.4 libapache2-mod-php7.4 php7.4-curl php7.4-gd php7.4-mbstring php7.4-xml wget curl

# Config PHP handler (corrige código na tela)
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

echo "✅ Apache + PHP7.4 OK! Teste: http://$(hostname -I | awk '{print $1}')/info.php"

# Cloudflare Tunnel
echo "🔐 Configurando Cloudflare Tunnel..."
cloudflared --version || {
    wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O /usr/local/bin/cloudflared
    chmod +x /usr/local/bin/cloudflared
}

read -p "Digite o DOMÍNIO (ex: seunovo.grythprogress.com.br): " DOMINIO
read -p "Digite o NOME do TÚNEL (ex: macb-site): " NOME_TUNEL

cloudflared tunnel login
sleep 5
ARQUIVO_CREDENCIAIS=$(ls ~/.cloudflared/*.json | head -1)

cloudflared tunnel create $NOME_TUNEL
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
systemctl enable cloudflared --now

echo "🎉 SITE ONLINE: https://$DOMINIO"
echo "📤 Coloque arquivos do Google Drive em /var/www/html/"
echo "📊 Logs: journalctl -u cloudflared -f | journalctl -u apache2 -f"
