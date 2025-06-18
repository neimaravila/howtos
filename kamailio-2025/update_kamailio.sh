#!/bin/bash
sudo sed -i "s/KAMAILIO_IPINTERNO/$IP_INTERNO/g; s/KAMAILIO_IP_EXTERNO/$IP_EXTERNO/g" /etc/kamailio/config.cfg

# Verifica se o IP_EXTERNO pertence a alguma interface de rede
if ip addr show | grep -w "$IP_EXTERNO" > /dev/null; then
    echo "IP_EXTERNO ($IP_EXTERNO) encontrado em uma interface de rede."

    # Altera a linha ##!define WITH_PUBLIC_IP para #!define WITH_PUBLIC_IP
    if grep -q "^##!define WITH_PUBLIC_IP" /etc/kamailio/config.cfg; then
        sed -i 's/^##!define WITH_PUBLIC_IP/#!define WITH_PUBLIC_IP/' /etc/kamailio/config.cfg
        echo "Linha alterada para: #!define WITH_PUBLIC_IP"
    else
        echo "A linha ##!define WITH_PUBLIC_IP não foi encontrada no arquivo."
    fi
else
    echo "IP_EXTERNO ($IP_EXTERNO) não pertence a nenhuma interface de rede. Nenhuma alteração feita."
fi
