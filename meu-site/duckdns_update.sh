#!/bin/bash

CONFIG_FILE="${HOME}/.duckdns_config"

# Carrega configurações se já existirem
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Se TOKEN ou DOMAIN não estiverem definidos, solicita ao usuário
if [ -z "$TOKEN" ] || [ -z "$DOMAIN" ]; then
    read -p "Digite seu token DuckDNS: " TOKEN
    read -p "Digite seu domínio DuckDNS: " DOMAIN
    echo "TOKEN=${TOKEN}" > "$CONFIG_FILE"
    echo "DOMAIN=${DOMAIN}" >> "$CONFIG_FILE"
    echo "Configuração salva em $CONFIG_FILE"
fi

# Atualiza o registro DuckDNS usando IPv6
RESPONSE=$(curl -s -6 "https://www.duckdns.org/update?domains=${DOMAIN}&token=${TOKEN}&ip=auto")
echo "Resposta do DuckDNS: $RESPONSE"

# Configura cron job para executar este script a cada 10 minutos
SCRIPT_PATH=$(readlink -f "$0")
(crontab -l 2>/dev/null | grep -Fv "$SCRIPT_PATH"; echo "*/10 * * * * $SCRIPT_PATH") | crontab -
echo "Cron job instalado para execução a cada 10 minutos."

# Exibe o endereço do site DuckDNS
echo "Seu site DuckDNS está disponível em: https://${DOMAIN}.duckdns.org"
