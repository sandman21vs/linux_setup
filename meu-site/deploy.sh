#!/bin/bash
set -e

# Se não estiver executando como root, reexecuta com sudo
if [ "$EUID" -ne 0 ]; then
  echo "Reexecutando com privilégios de root..."
  exec sudo bash "$0" "$@"
fi

CURRENT_DIR=$(pwd)
echo "Verificando se já existe um container 'meu-site'..."

if [ "$(docker ps -a -q -f name=^meu-site$)" ]; then
  echo "Container 'meu-site' já existe. Forçando remoção..."
  docker rm -f meu-site
fi

echo "Iniciando container Nginx para servir o site localizado em $CURRENT_DIR..."

docker run -d --name meu-site \
  -p 9001:80 \
  -v "$CURRENT_DIR":/usr/share/nginx/html \
  --restart always \
  nginx:latest

echo "Site rodando em http://localhost:9001"
