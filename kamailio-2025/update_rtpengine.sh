#!/bin/bash

# Verifica se as variáveis IP_EXTERNO e IP_INTERNO estão definidas
if [ -z "$IP_EXTERNO" ] || [ -z "$IP_INTERNO" ]; then
  echo "Erro: As variáveis IP_EXTERNO e/ou IP_INTERNO não estão definidas."
  exit 1
fi

# Verifica se o arquivo rtpengine.conf existe
if [ ! -f /etc/rtpengine/rtpengine.conf ]; then
  echo "Erro: Arquivo /etc/rtpengine/rtpengine.conf não encontrado."
  exit 1
fi

# Faz backup do arquivo de configuração
cp /etc/rtpengine/rtpengine.conf /etc/rtpengine/rtpengine.conf.bak
echo "Backup do arquivo /etc/rtpengine/rtpengine.conf criado."

# Verifica se o IP_EXTERNO está associado a alguma interface de rede
if ip addr show | grep -q "$IP_EXTERNO"; then
  echo "IP_EXTERNO ($IP_EXTERNO) encontrado em uma interface de rede."

  # Descomenta e substitui IP_INTERNO e IP_EXTERNO na linha desejada
  sed -i "s|^#interface = priv/IP_INTERNO;pub/IP_EXTERNO$|interface = priv/$IP_INTERNO;pub/$IP_EXTERNO|" /etc/rtpengine/rtpengine.conf
  echo "Arquivo /etc/rtpengine/rtpengine.conf atualizado: linha 'interface = priv/$IP_INTERNO;pub/$IP_EXTERNO' descomentada e atualizada."
else
  echo "IP_EXTERNO ($IP_EXTERNO) não está associado a nenhuma interface de rede."

  # Descomenta e substitui IP_INTERNO e IP_EXTERNO na linha alternativa
  sed -i "s|^#interface = priv/IP_INTERNO;pub/IP_INTERNO!IP_EXTERNO$|interface = priv/$IP_INTERNO;pub/$IP_INTERNO!$IP_EXTERNO|" /etc/rtpengine/rtpengine.conf
  echo "Arquivo /etc/rtpengine/rtpengine.conf atualizado: linha 'interface = priv/$IP_INTERNO;pub/$IP_INTERNO!$IP_EXTERNO' descomentada e atualizada."
fi

# Verifica se o IP_INTERNO está associado a alguma interface de rede
if ip addr show | grep -q "$IP_INTERNO"; then
  echo "IP_INTERNO ($IP_INTERNO) encontrado em uma interface de rede."

  # Substitui as linhas listen com IP_INTERNO
  sed -i "s|^listen-ng = IPINTERNO:2223$|listen-ng = $IP_INTERNO:2223|" /etc/rtpengine/rtpengine.conf
  sed -i "s|^listen-tcp = IPINTERNO:2230$|listen-tcp = $IP_INTERNO:2230|" /etc/rtpengine/rtpengine.conf
  sed -i "s|^listen-udp = IPINTERNO:12222$|listen-udp = $IP_INTERNO:12222|" /etc/rtpengine/rtpengine.conf
  sed -i "s|^listen-http = IPINTERNO:2225$|listen-http = $IP_INTERNO:2225|" /etc/rtpengine/rtpengine.conf
  sed -i "s|^listen-cli = IPINTERNO:2231$|listen-cli = $IP_INTERNO:2231|" /etc/rtpengine/rtpengine.conf
  echo "Arquivo /etc/rtpengine/rtpengine.conf atualizado: linhas 'listen-ng', 'listen-tcp', 'listen-udp', 'listen-http' e 'listen-cli' configuradas com IP_INTERNO ($IP_INTERNO)."
else
  echo "IP_INTERNO ($IP_INTERNO) não está associado a nenhuma interface de rede."

  # Substitui IP_INTERNO por IP_EXTERNO em todas as linhas listen
  sed -i "s|^listen-ng = IPINTERNO:2223$|listen-ng = $IP_EXTERNO:2223|" /etc/rtpengine/rtpengine.conf
  sed -i "s|^listen-tcp = IPINTERNO:2230$|listen-tcp = $IP_EXTERNO:2230|" /etc/rtpengine/rtpengine.conf
  sed -i "s|^listen-udp = IPINTERNO:12222$|listen-udp = $IP_EXTERNO:12222|" /etc/rtpengine/rtpengine.conf
  sed -i "s|^listen-http = IPINTERNO:2225$|listen-http = $IP_EXTERNO:2225|" /etc/rtpengine/rtpengine.conf
  sed -i "s|^listen-cli = IPINTERNO:2231$|listen-cli = $IP_EXTERNO:2231|" /etc/rtpengine/rtpengine.conf
  echo "Arquivo /etc/rtpengine/rtpengine.conf atualizado: linhas 'listen-ng', 'listen-tcp', 'listen-udp', 'listen-http' e 'listen-cli' configuradas com IP_EXTERNO ($IP_EXTERNO)."
fi
