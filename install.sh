#!/bin/bash
clear
echo "🚀 Hospedagem PHP TV Box - macbservices v2.0"

apt update && apt upgrade -y -qq
apt install -y apache2 php7.4 libapache2-mod-php7.4 php7.4-mysql php7.4-curl php7.4-gd php7.4-mbstring php7.4-xml php7.4-zip

cat > /etc/apache2/conf-available/php-handler.conf << 'EOF'
<FilesMatch \.php$>
    SetHandler application/x-httpd-php
</FilesMatch>
EOF

a2enconf php-handler && a2enmod php7.4 rewrite headers
echo "ServerName localhost" >> /etc/apache2/apache2.conf
sed -i 's/DirectoryIndex.*/DirectoryIndex index.php index.html index.htm/' /etc/apache2/mods-enabled/dir.conf
systemctl restart apache2

cat > /var/www/html/info.php << 'EOF'
<?php phpinfo(); ?><h1>✅ PHP OK!</h1>
EOF

echo "✅ PHP funcionando!"

mkdir -p /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflared.list
apt update && apt install cloudflared -y

cloudflared tunnel login
read -p "Pressione Enter após autenticar..."

read -p "Nome túnel: " NOME_TUNEL
read -p "Domínio: " DOMINIO

cloudflared tunnel create $NOME_TUNEL
ARQUIVO_CREDENCIAIS=$(ls ~/.cloudflared/*.json | head -n1)

mkdir -p /etc/cloudflared
cat > /etc/cloudflared/config.yml << EOF
tunnel: $(basename $ARQUIVO_CREDENCIAIS .json)
credentials-file: $ARQUIVO_CREDENCIAIS
ingress:
  - hostname: $DOMINIO
    service: http://localhost:80
  - service: http_status:404
EOF

cloudflared tunnel route dns $NOME_TUNEL $DOMINIO
cloudflared service install
systemctl enable cloudflared --now

echo "🎉 Site PHP online: https://$DOMINIO"
