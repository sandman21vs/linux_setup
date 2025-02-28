#!/bin/bash
set -e

echo "Atualizando a lista de pacotes..."
sudo apt update

# Lista de pacotes para instalar/atualizar
packages=(openssh-server micro btop python3 tailscale)

for pkg in "${packages[@]}"; do
    echo "Verificando o pacote $pkg..."
    if dpkg -s "$pkg" &>/dev/null; then
        echo "$pkg já está instalado. Atualizando se necessário..."
        sudo apt install -y "$pkg"
    else
        echo "Instalando $pkg..."
        sudo apt install -y "$pkg"
    fi
done

# Instalação do Docker
if ! command -v docker &>/dev/null; then
    echo "Docker não encontrado. Instalando Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh
else
    echo "Docker já está instalado. Atualizando se necessário..."
    sudo apt install -y docker-ce docker-ce-cli containerd.io
fi

# Instalação/Atualização do Portainer
if [ "$(sudo docker ps -a -q -f name=^portainer$)" ]; then
    echo "Portainer já está instalado. Atualizando a imagem e reiniciando o container..."
    sudo docker pull portainer/portainer-ce:latest
    sudo docker stop portainer && sudo docker rm portainer
else
    echo "Instalando Portainer..."
fi

# Cria o volume e inicia o container do Portainer
sudo docker volume create portainer_data
sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer \
  --restart always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest

# Cria a pasta para o site, se não existir
SITE_DIR="$HOME/meu-site"
if [ ! -d "$SITE_DIR" ]; then
    echo "Criando a pasta $SITE_DIR..."
    mkdir -p "$SITE_DIR"
fi

# Cria (ou atualiza) o container "meu-site" com o Nginx
if [ "$(sudo docker ps -a -q -f name=^meu-site$)" ]; then
    echo "Container 'meu-site' já existe. Atualizando a imagem e reiniciando o container..."
    sudo docker pull nginx:latest
    sudo docker stop meu-site && sudo docker rm meu-site
fi

echo "Criando o container 'meu-site'..."
sudo docker run -d --name meu-site -p 9001:80 \
  -v "$SITE_DIR":/usr/share/nginx/html \
  --restart always nginx:latest

echo "Instalação e configuração concluídas."
