```bash bash <(curl -sSL https://raw.githubusercontent.com/macbservices/hospedagem-linux-cloudflare/main/install.sh)


# 🚀 Hospedagem-TVBOX-PHP

**Instalação PHP + Apache + Cloudflare Tunnel em 1 comando no TV Box Ubuntu 18.04 (RK322x)**

## 📱 Instalação (2 minutos)

wget https://raw.githubusercontent.com/macbservices/hospedagem-linux-cloudflare/main/install.sh
chmod +x install.sh
./install.sh


**Digite quando pedir:**
- Domínio: `macbtv.grythprogress.com.br`
- Nome túnel: `macbtv-php`

## ✅ Resultado
- ✅ Apache + PHP7.4 funcionando
- ✅ Cloudflare Tunnel ativo
- ✅ Site PHP online sem IP público
- ✅ Otimizado para TV Box (ARM64)

## 📂 Deploy Site PHP

Exemplo: baixar seu site
cd /var/www/html
wget -r -k -l 10 -p -E -nc https://macbtv.grythprogress.com.br/

ou zip seu site → unzip site.zip


**Repo original:** https://macbtv.grythprogress.com.br
