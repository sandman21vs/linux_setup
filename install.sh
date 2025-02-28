#!/bin/bash

# Atualiza a lista de pacotes
sudo apt update

# Instala pacotes disponíveis no repositório
sudo apt install -y openssh-server micro btop python3 

# Instala o Tailscale (usando o script oficial)
curl -fsSL https://tailscale.com/install.sh | sh


