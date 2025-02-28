#!/bin/bash

# Atualiza a lista de pacotes
sudo apt update

# Instala pacotes disponíveis no repositório
#sudo apt install -y openssh-server micro btop python3

# Instala o Tailscale (usando o script oficial)
curl -fsSL https://tailscale.com/install.sh | sh

# Instala o Cloudflare Tunnel (cloudflared)
#curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o cloudflared.deb
#sudo dpkg -i cloudflared.deb
#rm cloudflared.deb
