#!/bin/bash
#
# Delete DEV environment
#
# Author: Miguel Perdices
#
# Version: 1.0 (Jun 2018)
#

# We verify it's running as root
if [ $EUID != 0 ]; then
    echo "Please run as root user"
    exit
fi

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 ENV SITE" >&2
  exit 1
fi

devEnv=$1
siteName=$2

site='led-dev'-$siteName-$devEnv
server_name='led-dev'-$siteName-$devEnv

pool=/etc/php-fpm.d/$site-php-fpm.conf
dataDir=/data
envDir=$dataDir/envs
httpdConf=$envDir/$devEnv/httpd
httpdLogs=$dataDir/logs/httpd/$site
sitesDir=$envDir/$devEnv/sites
sitePath=$sitesDir/$siteName

read -p "Va a borrar el site $2 del entorno $1. Esta acción NO se puede deshacer. ¿Está seguro? [y/n] " -n 1 -r
echo    #
if [[ $REPLY =~ ^[Yy]$ ]]
then
read -p "¿Has leído que esta acción NO se puede deshacer? [y/n] " -n 1 -r
echo    #
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        rm -rf $httpdConf/$siteName.conf
        rm -rf $httpdLogs
        rm -rf $sitePath
        rm -rf $pool
	echo "Site eliminado"
        # Reiniciamos servicios
        systemctl reload php-fpm.service
        systemctl reload nginx
    fi
fi
