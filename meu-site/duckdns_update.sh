#!/bin/bash
# DuckDNS Auto Setup Script
# Este script solicita as informações da sua conta DuckDNS e atualiza automaticamente
# o domínio com os IPs públicos (IPv4 e IPv6).

echo "=== Configuração Automática do DuckDNS ==="

# Solicita o e-mail (opcional) e informa que o tipo é free
read -p "Digite seu e-mail DuckDNS (opcional): " duck_email
echo "Tipo: free (padrão)"

# Solicita o token, com um valor padrão de exemplo
read -p "Digite seu token DuckDNS [padrão: your-token-here]: " duck_token
if [ -z "$duck_token" ]; then
  duck_token="your-token-here"
fi

# Solicita o domínio a ser atualizado (somente a parte antes de .duckdns.org)
read -p "Digite seu domínio DuckDNS (ex: exemplo): " duck_domain
if [ -z "$duck_domain" ]; then
  echo "Domínio é obrigatório!"
  exit 1
fi

# Informações adicionais (apenas para referência)
echo "Token gerado: exemplo"
echo "Data de criação: data de exemplo"

# Detecta o IP público IPv4
echo "Detectando IPv4 atual..."
ipv4=$(curl -4 -s ifconfig.me)
echo "IPv4 detectado: $ipv4"

# Detecta o IP público IPv6 (caso esteja disponível)
echo "Detectando IPv6 atual..."
ipv6=$(curl -6 -s ifconfig.me)
echo "IPv6 detectado: ${ipv6:-(não encontrado)}"

# Monta a URL de atualização com os parâmetros
update_url="https://www.duckdns.org/update?domains=${duck_domain}&token=${duck_token}&ip=${ipv4}&ipv6=${ipv6}"
echo "Atualizando DuckDNS com a URL:"
echo "$update_url"

# Chama a URL e captura a resposta
result=$(curl -k -s "$update_url")
echo "Resposta do DuckDNS: $result"
