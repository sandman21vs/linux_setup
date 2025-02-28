#!/bin/bash
set -e

# Define variáveis
USER_HOME="/home/$(logname)"
SITE_DIR="$USER_HOME/meu-site"
GIT_REPO="https://github.com/sandman21vs/linux_setup.git"
SUBDIR="meu-site"

echo "Atualizando os arquivos do site em $SITE_DIR a partir do repositório GitHub..."

# Cria o diretório do site, se não existir
if [ ! -d "$SITE_DIR" ]; then
  echo "Diretório $SITE_DIR não existe. Criando..."
  mkdir -p "$SITE_DIR"
fi

# Cria um diretório temporário para clonar o repositório
TEMP_DIR=$(mktemp -d)

echo "Clonando repositório..."
git clone "$GIT_REPO" "$TEMP_DIR"

# Usa rsync para copiar os arquivos da pasta SUBDIR do repositório para o SITE_DIR local
echo "Copiando arquivos..."
rsync -av --delete "$TEMP_DIR/$SUBDIR/" "$SITE_DIR/"

# Remove o diretório temporário
rm -rf "$TEMP_DIR"

echo "Atualização concluída! Os arquivos do site foram copiados para $SITE_DIR."
