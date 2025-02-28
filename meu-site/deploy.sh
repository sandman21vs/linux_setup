#!/bin/bash
set -e

# Se não estiver executando como root, reexecuta com sudo
if [ "$EUID" -ne 0 ]; then
  echo "Reexecutando com privilégios de root..."
  exec sudo bash "$0" "$@"
fi

echo "Executando como: $(whoami)"

# Verifica se o daemon do Docker está ativo; se não, tenta iniciá-lo
if ! systemctl is-active --quiet docker; then
  echo "Docker daemon não está ativo. Iniciando o Docker..."
  systemctl start docker
fi

CURRENT_DIR=$(pwd)
echo "Iniciando container Nginx para servir o site localizado em $CURRENT_DIR..."

# Força o uso de sudo mesmo se o script estiver rodando como root
sudo docker run -d --name meu-site \
  -p 9001:80 \
  -v "$CURRENT_DIR":/usr/share/nginx/html \
  --restart always \
  nginx:latest

echo "Site rodando em http://localhost:9001"
