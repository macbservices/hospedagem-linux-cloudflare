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
