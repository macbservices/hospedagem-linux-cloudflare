#!/bin/bash
# Hospedagem-TVBOX-PHP v2.0 - Apache + PHP7.4 + Cloudflare Tunnel (RK322x TV Box)
clear
echo "🚀 Hospedagem PHP TV Box - macbservices (Otimizado para macbtv.grythprogress.com.br)"

# Atualizar sistema
apt update && apt upgrade -y -qq

# Instalar Apache + PHP7.4 + Extensões (corrige problemas do site)
apt install -y apache2 php7.4 libapache2-mod-php7.4 php7.4-mysql php7.4-curl php7.4-gd php7.4-mbstring php7.4-xml php7.4-zip unzip wget curl

# Configurar PHP Handler (SOLUCIONA código PHP aparecendo na tela)
cat > /etc/apache2/conf-available/php-handler.conf << 'EOF'
<FilesMatch \.php$>
    SetHandler application/x-httpd-php
</FilesMatch>
<FilesMatch \.phps$>
    SetHandler application/x-httpd-php-source
</FilesMatch>
EOF

a2enconf php-handler
a2enmod php7.4 rewrite headers
echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Priorizar index.php
sed -i 's/DirectoryIndex.*/DirectoryIndex index.php index.html index.htm/' /etc/apache2/mods-enabled/dir.conf

# Reiniciar Apache
systemctl restart apache2

# Instalar Cloudflare Tunnel (ARM64 para TV Box RK322x)
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64
chmod +x cloudflared-linux-arm64
mv cloudflared-linux-arm64 /usr/local/bin/cloudflared

# Configurar Cloudflare Tunnel
read -p "🔗 Domínio (ex: macbtv.grythprogress.com.br): " DOMINIO
read -p "🏷 Nome do túnel (ex: macbtv-php): " TUNEL_NAME

mkdir -p /etc/cloudflared
cat > /etc/cloudflared/config.yml << EOF
tunnel: $TUNEL_NAME
credentials-file: /etc/cloudflared/${TUNEL_NAME}.json

ingress:
  - hostname: $DOMINIO
    service: http://localhost:80
  - service: http_status:404
EOF

# Criar serviço systemd
cat > /etc/systemd/system/cloudflared.service << EOF
[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
ExecStart=/usr/local/bin/cloudflared tunnel --config /etc/cloudflared/config.yml run
Restart=always
User=root
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable cloudflared --now

# Arquivo teste PHP
cat > /var/www/html/info.php << 'EOF'
<?php phpinfo(); ?>
<h1>✅ PHP Funcionando no TV Box! Copie seus arquivos PHP em /var/www/html/</h1>
EOF

# Permissões
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo "✅ INSTALAÇÃO CONCLUÍDA em $(date)"
echo "🌐 Teste local: http://$(hostname -I | awk '{print $1}'):80/info.php"
echo "🔗 Site online: https://$DOMINIO"
echo "📊 Logs Apache: tail -f /var/log/apache2/error.log"
echo "📊 Logs Tunnel: journalctl -u cloudflared -f"
echo ""
echo "👉 1. Cole seus arquivos PHP em /var/www/html/"
echo "👉 2. Crie túnel no dashboard Cloudflare: $TUNEL_NAME"
echo "👉 3. Adicione DNS: $DOMINIO -> CNAME tunnel"
