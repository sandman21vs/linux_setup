#!/bin/bash
# Atualização automática do DuckDNS via IPv6 para expor a porta 9001
# Uso: ./duckdns_ipv6.sh SEU_TOKEN SEU_DOMAIN
# Exemplo: ./duckdns_ipv6.sh your-token-here your-domain

# Verifica se os parâmetros foram informados
if [ "$#" -lt 2 ]; then
  echo "Uso: $0 <token> <domain>"
  exit 1
fi

TOKEN="$1"
DOMAIN="$2"

# Detecta o IPv6 público
ipv6=$(curl -6 -s ifconfig.me)
if [ -z "$ipv6" ]; then
  echo "Erro: Não foi possível detectar um endereço IPv6."
  exit 1
fi

echo "IPv6 detectado: $ipv6"

# Atualiza o DuckDNS com o IPv6 (deixa o IPv4 em branco)
UPDATE_URL="https://www.duckdns.org/update?domains=${DOMAIN}&token=${TOKEN}&ip=&ipv6=${ipv6}"
response=$(curl -k -s "$UPDATE_URL")

echo "Resposta do DuckDNS: $response"

# Para acessar seu serviço na porta 9001, use:
echo "Acesse: http://${DOMAIN}.duckdns.org:9001"
