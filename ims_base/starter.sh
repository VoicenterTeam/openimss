#!/bin/bash

printYelwStar(){
    Clr="\033[0;33m"
    noClr="\033[0m"
    arrowAdd=" \342\230\205 "
    printf "${Clr}${arrowAdd}$1${noClr}\n"
}

## test case:
##/usr/bin/env | tr '\n' ' ' | xargs jo -p > /etc/env2obj.json
#/usr/bin/mo /opt/voicenter_deploy/extension_proxy/extension_proxy.mustache > /opt/voicenter_deploy/extension_proxy/parameters.json



templateName="${OPENSIPS_TEMPLATE:=general}" 
echo "templateName is $templateName"

if [ "$oSipsRole" = "extension_proxy" ]
then
    #mysql-start:
    printYelwStar "Starting MYSQL-server: ..."
    /usr/sbin/mysqld --user="root" &
    sleep 5
    mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '$dbPass'" 2>/dev/null | grep -v "mysql: [Warning] Using a password on the command line interface can be insecure."
    printYelwStar "Starting done ...\n"
fi

#parsing params from env:
printYelwStar "Importing ENV-params: ..."
#/usr/bin/mo /opt/voicenter_deploy/$oSipsRole/$oSipsRole.mustache > /opt/voicenter_deploy/$oSipsRole/parameters.json
#/usr/bin/mo /opt/voicenter_deploy/dkrCfgs/$oSipsRole.mustache > /opt/voicenter_deploy/$oSipsRole/parameters.json
printYelwStar "Importing done ...\n"

#
#/usr/bin/mo /opt/voicenter_deploy/$oSipsRole/mysql_preinstall.mustache > /opt/voicenter_deploy/mysql_preinstall

#
#chmod +x /opt/voicenter_deploy/mysql_preinstall && cd /opt/voicenter_deploy/ && ./mysql_preinstall
#apt install mysql-server -y

#/sbin/opensips -FE

printYelwStar "Importing docker-cfg for OPENSIPS-server: ..."

#/usr/bin/opensips_configurator
printYelwStar "Importing docker-cfg done ..."
#check if local.m4.template exsist if not copy from /opt/opensips/template/${templateName}/* to /etc/opensips
if [ -e  /etc/opensips/opensips_proxy.m4 ];
then
    printYelwStar "/etc/opensips/opensips_proxy.m4 - File exists. Docker has been deployed. not overwriting templates configurations."
else
    printYelwStar "/etc/opensips/opensips_proxy.m4 does not esist, this is a new setup, deploying templates."
    cp -rf /opt/opensips/templates/$templateName/*  /etc/opensips
fi
printYelwStar "Starting OPENSIPS-process: ..."
#/sbin/opensips-m4cfg
printYelwStar "setting up m4 configurations ..."
m4 /etc/opensips/opensips.m4.template /etc/opensips/opensips_proxy.m4 > /etc/opensips/opensips.cfg
if [ "$templateName" = "pcscf" ];
then
    printYelwStar "Adding route to ${UPF_IP}"
    route add -net 192.168.101.0 netmask 255.255.255.0 gw ${UPF_IP}
fi

exec opensips -D -f /etc/opensips/opensips.cfg
