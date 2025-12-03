#!/bin/bash
# Hospedagem-TVBOX-PHP v1.0 - Apache + PHP7.4 + Cloudflare Tunnel

echo "🚀 Iniciando Hospedagem PHP no TV Box Ubuntu 18.04..."

# Atualizar sistema
apt update && apt upgrade -y

# Instalar Apache + PHP7.4
apt install -y apache2 php7.4 libapache2-mod-php7.4 php7.4-mysql php7.4-curl php7.4-gd php7.4-mbstring php7.4-xml

# Habilitar PHP e módulos
a2enmod php7.4 rewrite
echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Configurar index.php como prioridade
echo '<Directory "/var/www/html">' > /etc/apache2/apache2.conf.backup
echo '    DirectoryIndex index.php index.html index.htm' >> /etc/apache2/apache2.conf.backup

# Configurar handler PHP (corrige problema do seu site)
cat >> /etc/apache2/conf-available/php-handler.conf << 'EOF'
<FilesMatch \.php$>
    SetHandler application/x-httpd-php
</FilesMatch>
<FilesMatch \.phps$>
    SetHandler application/x-httpd-php-source
</FilesMatch>
EOF

a2enconf php-handler

# Reiniciar Apache
systemctl restart apache2

# Instalar Cloudflare Tunnel
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64.deb
dpkg -i cloudflared-linux-arm64.deb

# Criar config Cloudflare (pergunta domínio e nome túnel)
read -p "Digite seu DOMÍNIO (ex: macbtv.grythprogress.com.br): " DOMINIO
read -p "Digite NOME do túnel (ex: site-php): " TUNEL_NAME

mkdir -p /etc/cloudflared
cp config.yml.template /etc/cloudflared/config.yml

sed -i "s/DOMINIO/$DOMINIO/g" /etc/cloudflared/config.yml
sed -i "s/TUNEL_NAME/$TUNEL_NAME/g" /etc/cloudflared/config.yml

# Criar serviço Cloudflare
cat > /etc/systemd/system/cloudflared.service << EOF
[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
ExecStart=/usr/local/bin/cloudflared tunnel --config /etc/cloudflared/config.yml run
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable cloudflared
systemctl start cloudflared

# Criar teste PHP
cat > /var/www/html/info.php << 'EOF'
<?php phpinfo(); ?>
EOF

echo "✅ INSTALAÇÃO CONCLUÍDA!"
echo "🌐 Site PHP: http://localhost"
echo "🔗 Túnel ativo: $DOMINIO"
echo "📊 Teste PHP: http://SEU_IP/info.php"
echo "⚙️ Logs: journalctl -u cloudflared -f"
echo ""
echo "👉 Cole seus arquivos PHP em /var/www/html/"
