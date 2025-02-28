#!/bin/bash
set -e

# Atualiza a lista de pacotes no início
echo "Atualizando a lista de pacotes..."
apt update

# Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
  echo "Este script precisa ser executado com privilégios de root."
  echo "Por favor, execute: sudo bash <(curl -fsSL https://raw.githubusercontent.com/sandman21vs/linux_setup/main/install.sh)"
  exit 1
fi

# Forçar a criação do grupo 'docker', se não existir
if ! getent group docker > /dev/null 2>&1; then
  echo "Grupo docker não existe. Criando o grupo..."
  groupadd docker
else
  echo "O grupo docker já existe."
fi

# Adiciona o usuário original (se existir) ao grupo docker, se ainda não estiver
USER_TO_ADD="${SUDO_USER:-$USER}"
if ! id -nG "$USER_TO_ADD" | grep -qw "docker"; then
  echo "Adicionando o usuário $USER_TO_ADD ao grupo docker..."
  usermod -aG docker "$USER_TO_ADD"
  echo "Atenção: Faça logout e login novamente para que a alteração tenha efeito."
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
