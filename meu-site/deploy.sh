#!/bin/bash
set -e

# Se não estiver executando como root, reexecuta com sudo
if [ "$EUID" -ne 0 ]; then
  echo "Reexecutando com privilégios de root..."
  exec sudo bash "$0" "$@"
fi

CURRENT_DIR=$(pwd)
echo "Diretório atual: $CURRENT_DIR"

# Verifica se index.html existe no diretório atual.
if [ -f "$CURRENT_DIR/index.html" ]; then
  SITE_DIR="$CURRENT_DIR"
else
  # Se não existir, verifica se existe em uma subpasta 'meu-site'
  if [ -d "$CURRENT_DIR/meu-site" ] && [ -f "$CURRENT_DIR/meu-site/index.html" ]; then
    echo "index.html não encontrado no diretório atual, mas encontrado em '$CURRENT_DIR/meu-site'."
    SITE_DIR="$CURRENT_DIR/meu-site"
  else
    echo "index.html não foi encontrado. Verifique a estrutura de diretórios."
    exit 1
  fi
fi

echo "Servindo arquivos a partir de: $SITE_DIR"

# Ajusta as permissões para garantir que o Nginx consiga ler os arquivos
find "$SITE_DIR" -type d -exec chmod 755 {} \;
find "$SITE_DIR" -type f -exec chmod 644 {} \;

# Remove o container 'meu-site' existente, se houver
if [ "$(docker ps -a -q -f name=^meu-site$)" ]; then
  echo "Container 'meu-site' já existe. Removendo..."
  docker rm -f meu-site
fi

echo "Iniciando container Nginx para servir o site..."
docker run -d --name meu-site \
  -p 9001:80 \
  -v "$SITE_DIR":/usr/share/nginx/html \
  --restart always \
  nginx:latest

echo "Site rodando em http://localhost:9001"
