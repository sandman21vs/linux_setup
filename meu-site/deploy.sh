#!/bin/bash
set -e

# Se não estiver executando como root, reexecuta com sudo
if [ "$EUID" -ne 0 ]; then
  echo "Reexecutando com privilégios de root..."
  exec sudo bash "$0" "$@"
fi

CURRENT_DIR=$(pwd)
SITE_DIR="$CURRENT_DIR"  # considerando que você está dentro da pasta "meu-site"

echo "Ajustando permissões para $SITE_DIR..."
# Define permissões: diretórios 755 e arquivos 644
find "$SITE_DIR" -type d -exec chmod 755 {} \;
find "$SITE_DIR" -type f -exec chmod 644 {} \;

echo "Verificando se já existe um container 'meu-site'..."
if [ "$(docker ps -a -q -f name=^meu-site$)" ]; then
  echo "Container 'meu-site' já existe. Forçando remoção..."
  docker rm -f meu-site
fi

echo "Iniciando container Nginx para servir o site localizado em $SITE_DIR..."
docker run -d --name meu-site \
  -p 9001:80 \
  -v "$SITE_DIR":/usr/share/nginx/html \
  --restart always \
  nginx:latest

echo "Site rodando em http://localhost:9001"
