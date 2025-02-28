#!/bin/bash
set -e

# AVISO: Este script removerá todos os componentes instalados pelo repositório,
# incluindo containers Docker, volumes, imagens, pacotes instalados e os arquivos
# e diretórios criados (como o diretório do site).
# Use com extrema cautela, pois a remoção é irreversível.

# Se não estiver executando como root, reexecuta com sudo
if [ "$EUID" -ne 0 ]; then
  echo "Reexecutando com privilégios de root..."
  exec sudo bash "$0" "$@"
fi

echo "Iniciando remoção de todos os componentes instalados..."

# Remover containers Docker (forçando remoção, se existirem)
echo "Removendo containers Docker 'meu-site' e 'portainer' (se existirem)..."
docker rm -f meu-site portainer 2>/dev/null || echo "Nenhum container 'meu-site' ou 'portainer' encontrado."

# Remover volumes Docker utilizados
echo "Removendo volumes Docker (portainer_data)..."
docker volume rm portainer_data 2>/dev/null || echo "Volume 'portainer_data' não encontrado."

# Remover imagens Docker específicas (Portainer e Nginx)
echo "Removendo imagens Docker (portainer/portainer-ce:latest e nginx:latest)..."
docker rmi -f portainer/portainer-ce:latest nginx:latest 2>/dev/null || echo "Imagens já removidas ou não encontradas."

# Remover pacotes instalados via apt (Docker, Tailscale, Micro e Btop)
echo "Removendo pacotes instalados (docker-ce, docker-ce-cli, containerd.io, tailscale, micro, btop)..."
apt-get remove --purge -y docker-ce docker-ce-cli containerd.io tailscale micro btop || echo "Erro ao remover algum pacote, continuando..."
apt-get autoremove -y
apt-get autoclean -y

# Remover o diretório do site criado no home do usuário (se existir)
if [ -n "$SUDO_USER" ]; then
  USER_HOME=$(eval echo "~$SUDO_USER")
else
  USER_HOME=$HOME
fi

SITE_DIR="$USER_HOME/meu-site"
if [ -d "$SITE_DIR" ]; then
  echo "Removendo o diretório do site: $SITE_DIR"
  rm -rf "$SITE_DIR"
else
  echo "Diretório do site ($SITE_DIR) não encontrado."
fi

echo "Remoção concluída. Todos os componentes instalados e arquivos gerados foram removidos."
