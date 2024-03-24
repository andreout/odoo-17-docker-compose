#!/bin/bash
DESTINATION=$1
PORT=$2
CHAT=$3
MASTERPASSWORD=$4
# Verifica se o número de parâmetros é igual a 4
if [ "$#" -ne 4 ]; then
    read -p "Informe o destino do clone do repositório: " DESTINATION
    read -p "Informe a porta para o Odoo: " PORT
    read -p "Informe a porta para o Live Chat: " CHAT
    read -p  "Informe a senha mestre do Odoo: " MASTERPASSWORD
fi
createodoo(){
#create network external to link with other services
docker network create -d bridge netproxy

# clone Odoo directory
git clone --depth=1 https://github.com/andreout/odoo-17-docker-compose $DESTINATION
rm -rf $DESTINATION/.git
# set permission
mkdir -p $DESTINATION/postgresql
sudo chmod -R 777 $DESTINATION
# config
if grep -qF "fs.inotify.max_user_watches" /etc/sysctl.conf; then echo $(grep -F "fs.inotify.max_user_watches" /etc/sysctl.conf); else echo "fs.inotify.max_user_watches = 524288" | sudo tee -a /etc/sysctl.conf; fi
sudo sysctl -p
sed -i 's/10017/'$PORT'/g' $DESTINATION/docker-compose.yml
sed -i 's/20017/'$CHAT'/g' $DESTINATION/docker-compose.yml
#CONFIGURAR MASTER PASSWORD DO ODOO
sed -i 's/minh4passAleat0ria/'$MASTERPASSWORD'/g' $DESTINATION/etc/odoo.conf
# run Odoo
docker-compose -f $DESTINATION/docker-compose.yml up -d

echo 'Started Odoo @ http://localhost:'$PORT' | Master Password: '$MASTERPASSWORD' | Live chat port: '$CHAT
}
createodoo
