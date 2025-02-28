#!/bin/bash
set -e

# Garante que estamos no diretório raiz do projeto "meu-site"
CURRENT_DIR=$(pwd)
echo "Iniciando container Nginx para servir o site localizado em $CURRENT_DIR..."

docker run -d --name meu-site \
  -p 9001:80 \
  -v "$CURRENT_DIR":/usr/share/nginx/html \
  --restart always \
  nginx:latest

echo "Site rodando em http://localhost:9001"
