#!/bin/bash

# Função para verificar se há interfaces de rede ativas
check_network_interfaces() {
    if ! ip link show | grep -q "state UP"; then
        echo "Nenhuma interface de rede ativa encontrada."
        IP_INTERNO="Nenhum"
        IP_EXTERNO="Nenhum"
        IP_IPV6="Nenhum"
        return 1
    fi
    return 0
}

# Função para verificar conectividade com a internet
check_internet() {
    if ! ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
        return 1
    fi
    return 0
}

# Verificar interfaces de rede
check_network_interfaces || {
    echo "IP_INTERNO: $IP_INTERNO"
    echo "IP_EXTERNO: $IP_EXTERNO"
    echo "IP_IPV6: $IP_IPV6"
    exit 1
}
# Obter IPs IPv4 internos (privados)
IP_INTERNO=$(ip -4 addr show scope global | grep inet | awk '{print $2}' | cut -d'/' -f1 | grep -E '^(10\..*|172\.(1[6-9]|2[0-9]|3[0-1])\..*|192\.168\..*)' | tr '\n' ' ' | sed 's/ $//')

# Obter IPs IPv4 externos (públicos) pelas interfaces
IP_EXTERNO=$(ip -4 addr show scope global | grep inet | awk '{print $2}' | cut -d'/' -f1 | grep -vE '^(10\..*|172\.(1[6-9]|2[0-9]|3[0-1])\..*|192\.168\..*)' | tr '\n' ' ' | sed 's/ $//')

# Se IP_EXTERNO estiver vazio, tentar obter via ifconfig.me
if [ -z "$IP_EXTERNO" ]; then
    if check_internet; then
        IP_EXTERNO=$(curl -4 -s --connect-timeout 5 ifconfig.me 2>/dev/null)
        if [ -z "$IP_EXTERNO" ]; then
            IP_EXTERNO="Nenhum (falha ao consultar ifconfig.me)"
        fi
    else
        IP_EXTERNO="Nenhum (sem conectividade com a internet)"
    fi
fi

# Obter IPs IPv6 (apenas globais, excluindo link-local)
IP_IPV6=$(ip -6 addr show scope global | grep inet6 | awk '{print $2}' | cut -d'/' -f1 | grep -vE '^fe80::' | tr '\n' ' ' | sed 's/ $//')

# Tratar caso de IPs internos ausentes
if [ -z "$IP_INTERNO" ]; then
    IP_INTERNO="Nenhum (sem placa de rede interna ou IPs privados)"
fi

# Tratar casos vazios para IPs externos e IPv6
[ -z "$IP_EXTERNO" ] && IP_EXTERNO="Nenhum"
[ -z "$IP_IPV6" ] && IP_IPV6="Nenhum"

# Exibir resultados
echo "IP_INTERNO: $IP_INTERNO"
echo "IP_EXTERNO: $IP_EXTERNO"
echo "IP_IPV6: $IP_IPV6"

# Exportar Variaveis
export IP_INTERNO=$IP_INTERNO
export IP_EXTERNO=$IP_EXTERNO
export IP_IPV6=$IP_IPV6
