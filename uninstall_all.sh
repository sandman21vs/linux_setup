#!/bin/bash
set -e

# AVISO: Este script removerá todos os componentes instalados pelos scripts deste repositório,
# incluindo containers Docker, volumes, imagens e os pacotes instalados (exceto pacotes essenciais).
# Use com cuidado, pois pode impactar serviços importantes.
# Este script foi concebido para ser colocado na raiz do repositório "linux_setup" (em main) como "uninstall_all.sh".

# Se não estiver executando como root, reexecuta com sudo
if [ "$EUID" -ne 0 ]; then
  echo "Reexecutando com privilégios de root..."
  exec sudo bash "$0" "$@"
fi

echo "Iniciando remoção de todos os componentes instalados pelo repositório..."

# Remover containers Docker (forçando remoção, se existirem)
echo "Removendo containers Docker 'meu-site' e 'portainer' (se existirem)..."
docker rm -f meu-site portainer 2>/dev/null || echo "Nenhum container 'meu-site' ou 'portainer' encontrado."

# Remover volumes Docker (por exemplo, portainer_data)
echo "Removendo volumes Docker utilizados (portainer_data)..."
docker volume rm portainer_data 2>/dev/null || echo "Volume 'portainer_data' não encontrado."

# Remover imagens Docker específicas (Portainer e Nginx)
echo "Removendo imagens Docker utilizadas (portainer/portainer-ce e nginx)..."
docker rmi -f portainer/portainer-ce:latest nginx:latest 2>/dev/null || echo "Imagens já removidas ou não encontradas."

# Remover pacotes instalados (via apt)
echo "Removendo pacotes instalados (Docker, Tailscale, Micro e Btop)..."
apt-get remove --purge -y docker-ce docker-ce-cli containerd.io tailscale micro btop || echo "Erro ao remover algum pacote, continuando..."
apt-get autoremove -y
apt-get autoclean -y

echo "Remoção concluída. Todos os componentes instalados foram desinstalados."
