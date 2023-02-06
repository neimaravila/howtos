#!/bin/bash
echo "Instalador Kamailio Multi Asterisk"
echo "Configurando Repositorios"

sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
sudo dnf config-manager --set-enabled ol9_codeready_builder
sudo crb enable
sudo dnf -y install https://opensource.vsphone.com.br/vsphone-opensource.rpm

echo "Instalando RTPEngine"
sudo dnf -y install ngcp-rtpengine ngcp-rtpengine-kernel ngcp-rtpengine-dkms iptables-services iptables-devel

echo "Instalando Kamailio"
sudo dnf -y install kamailio kamailio-websocket \
kamailio-postgresql kamailio-jansson kamailio-presence kamailio-outbound \
kamailio-regex kamailio-utils kamailio-json kamailio-uuid kamailio-tcpops \
kamailio-tls kamailio-dmq_userloc kamailio-geoip2 sngrep

echo "Instalando PostgreSQL"
sudo dnf -y install postgresql-server

echo "Configuracao de Servicos"
echo "Carregando Enderecos IP"
export DOMINIO_BASE=pabxip.com.br
export IPINTERNO=$(hostname -I | cut -d' ' -f1)
export IPEXTERNO=$(curl --silent ifconfig.io)


echo "Ajustando Firewall"
sudo systemctl disable firewalld
sudo systemctl stop firewalld
sudo systemctl enable iptables.service
sudo systemctl start iptables.service
sudo iptables -I INPUT -p udp -m udp --dport 5060 -j ACCEPT
sudo iptables -I INPUT -p tcp -m tcp --dport 5060 -j ACCEPT
sudo iptables -I INPUT -p tcp -m tcp --dport 5061 -j ACCEPT
sudo iptables -I INPUT -p tcp -m tcp --dport 8080 -j ACCEPT
sudo iptables -I INPUT -p tcp -m tcp --dport 9443 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 10000:20000 -j ACCEPT
sudo service iptables save


echo "Ajustando RTPEngine"
sudo wget https://raw.githubusercontent.com/neimaravila/howtos/main/kamailio-2023/rtpengine-nat.conf -O /etc/rtpengine/rtpengine.conf
sudo sed -i "s/IPINTERNO/$IPINTERNO/g" /etc/rtpengine/rtpengine.conf
sudo sed -i "s/IPEXTERNO/$IPEXTERNO/g" /etc/rtpengine/rtpengine.conf

echo "Inicializando RTPEngine"
sudo systemctl enable rtpengine
sudo systemctl start rtpengine
sudo service rtpengine status

echo "Ajustando PostgreSQL"
sudo postgresql-setup --initdb --unit postgresql
sudo sed -i 's/ident/trust/g' /var/lib/pgsql/data/pg_hba.conf
sudo sed -i 's/peer/trust/g' /var/lib/pgsql/data/pg_hba.conf


echo "Inicializando PostgreSQL"
sudo systemctl enable postgresql.service
sudo systemctl start postgresql.service

echo "Ajustando Kamailio"
sudo wget https://raw.githubusercontent.com/neimaravila/howtos/main/kamailio-2023/kamctlrc -O /etc/kamailio/kamctlrc
sudo kamdbctl create
sudo wget https://raw.githubusercontent.com/neimaravila/howtos/main/kamailio-2023/tabelas_view.sql -O /tmp/tabelas_view.sql
sudo psql -U postgres -d kamailio < /tmp/tabelas_view.sql
sudo wget https://raw.githubusercontent.com/neimaravila/howtos/main/kamailio-2023/config.cfg -O /etc/kamailio/config.cfg
sudo wget https://raw.githubusercontent.com/neimaravila/howtos/main/kamailio-2023/kamailio.cfg -O /etc/kamailio/kamailio.cfg
sudo chown kamailio.kamailio /etc/kamailio/*.cfg
sudo sed -i "s/KAMAILIO_IPINTERNO/$IPINTERNO/g" /etc/kamailio/config.cfg
sudo sed -i "s/KAMAILIO_IP_EXTERNO/$IPEXTERNO/g" /etc/kamailio/config.cfg

echo "Gerando Certificado Auto-Assinado"
openssl req -x509 -newkey rsa:4096 -keyout /etc/kamailio/kamailio-selfsigned.key \
-out /etc/kamailio/kamailio-selfsigned.pem -days 365 -subj "/C=BR/ST=Minas Gerais/L=Belo Horizonte/O=FAL/OU=FAL/CN=kamailio.pabxip.com.br" \
-nodes -sha256
sudo chown kamailio.kamailio /etc/kamailio/kamailio-selfsigned*

echo "Inicializando Kamailio" 
sudo systemctl enable kamailio
sudo systemctl start kamailio
sudo systemctl status kamailio


echo "Baixando KSS - Kamailio Stupid Script"
sudo wget https://raw.githubusercontent.com/neimaravila/howtos/main/kamailio-2023/kss -O /usr/bin/kss
sudo chmod +x /usr/bin/kss

echo "Kamailio Instalado. Utilize os comando kss para administrar o servidor"
