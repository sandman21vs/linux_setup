#!/bin/bash
set -e

# Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
  echo "Este script precisa ser executado com privilégios de root."
  echo "Por favor, execute: sudo bash <(curl -fsSL https://raw.githubusercontent.com/sandman21vs/linux_setup/main/install.sh)"
  exit 1
fi

# Atualiza a lista de pacotes
echo "Atualizando a lista de pacotes..."
apt update

# Instala o Docker se não estiver instalado
if ! command -v docker &>/dev/null; then
    echo "Docker não encontrado. Instalando Docker..."
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    sh /tmp/get-docker.sh
    rm /tmp/get-docker.sh
else
    echo "Docker já está instalado. Atualizando se necessário..."
    apt install -y docker-ce docker-ce-cli containerd.io
fi

# Verifica se o grupo docker existe, se não, cria o grupo
echo "Verificando se o grupo 'docker' existe..."
if ! getent group docker >/dev/null; then
  echo "Grupo 'docker' não encontrado. Criando o grupo..."
  groupadd docker
else
  echo "O grupo 'docker' já existe."
fi

# Adiciona o usuário ao grupo docker, se ainda não estiver
USER_TO_ADD="${SUDO_USER:-$USER}"
if ! id -nG "$USER_TO_ADD" | grep -qw "docker"; then
  echo "Adicionando o usuário $USER_TO_ADD ao grupo docker..."
  usermod -aG docker "$USER_TO_ADD"
  # Aplicando a alteração do grupo ao usuário sem a necessidade de logout
  newgrp docker <<EOF
  # Comando para verificar se o Docker está funcionando
  docker run hello-world
EOF
  echo "O usuário $USER_TO_ADD foi adicionado ao grupo docker e a configuração foi aplicada."
else
  echo "O usuário $USER_TO_ADD já faz parte do grupo docker."
fi

# Lista de pacotes a verificar/instalar
packages=(openssh-server micro btop python3 tailscale)

for pkg in "${packages[@]}"; do
    echo "Verificando o pacote $pkg..."
    if dpkg -s "$pkg" &>/dev/null; then
        echo "$pkg já está instalado. Atualizando se necessário..."
        apt install -y "$pkg"
    else
        echo "Instalando $pkg..."
        apt install -y "$pkg"
    fi
done

# Instalação/Atualização do Portainer
if [ "$(docker ps -a -q -f name=^portainer$)" ]; then
    echo "Portainer já está instalado. Atualizando a imagem e reiniciando o container..."
    docker pull portainer/portainer-ce:latest
    docker stop portainer && docker rm portainer
else
    echo "Instalando Portainer..."
fi

docker volume create portainer_data
docker run -d -p 8000:8000 -p 9000:9443 --name portainer \
  --restart always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest

# Define o diretório do site na pasta home do usuário original
if [ -n "$SUDO_USER" ]; then
  USER_HOME=$(eval echo "~$SUDO_USER")
else
  USER_HOME=$HOME
fi

SITE_DIR="$USER_HOME/meu-site"
if [ ! -d "$SITE_DIR" ]; then
    echo "Criando a pasta $SITE_DIR..."
    mkdir -p "$SITE_DIR"
    chown "$USER_TO_ADD":"$USER_TO_ADD" "$SITE_DIR"
fi

# Se o diretório estiver vazio, copia os arquivos padrão do Nginx para ele
if [ -z "$(ls -A "$SITE_DIR")" ]; then
    echo "O diretório $SITE_DIR está vazio. Copiando arquivos padrão do Nginx..."
    docker run --rm -v "$SITE_DIR":/target nginx sh -c 'cp -R /usr/share/nginx/html/. /target/'
fi

# Cria (ou atualiza) o container "meu-site" com a imagem Nginx
if [ "$(docker ps -a -q -f name=^meu-site$)" ]; then
    echo "Container 'meu-site' já existe. Atualizando a imagem e reiniciando o container..."
    docker pull nginx:latest
    docker stop meu-site && docker rm meu-site
fi

echo "Criando o container 'meu-site'..."
docker run -d --name meu-site -p 9001:80 \
  -v "$SITE_DIR":/usr/share/nginx/html \
  --restart always nginx:latest

echo "Instalação e configuração concluídas."
