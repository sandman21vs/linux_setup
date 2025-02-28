#!/bin/bash
set -e

# Se não estiver executando como root, reexecuta com sudo
if [ "$EUID" -ne 0 ]; then
  echo "Reexecutando com privilégios de root..."
  exec sudo bash "$0" "$@"
fi

# Adiciona o usuário original (se existir) ao grupo docker, se ainda não estiver
USER_TO_ADD="${SUDO_USER:-$USER}"
if ! id -nG "$USER_TO_ADD" | grep -qw "docker"; then
  echo "Adicionando o usuário $USER_TO_ADD ao grupo docker..."
  usermod -aG docker "$USER_TO_ADD"
  echo "Atenção: Faça logout e login novamente para que a alteração tenha efeito."
fi

echo "Atualizando a lista de pacotes..."
apt update

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

# Instalação do Docker
if ! command -v docker &>/dev/null; then
    echo "Docker não encontrado. Instalando Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
else
    echo "Docker já está instalado. Atualizando se necessário..."
    apt install -y docker-ce docker-ce-cli containerd.io
fi

# Instalação/Atualização do Portainer
if [ "$(docker ps -a -q -f name=^portainer$)" ]; then
    echo "Portainer já está instalado. Atualizando a imagem e reiniciando o container..."
    docker pull portainer/portainer-ce:latest
    docker stop portainer && docker rm portainer
else
    echo "Instalando Portainer..."
fi

docker volume create portainer_data
docker run -d -p 8000:8000 -p 9443:9443 --name portainer \
  --restart always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest

# Define o diretório do site na pasta home do usuário original (não em /root)
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

# Cria (ou atualiza) o container "meu-site" com o Nginx
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
