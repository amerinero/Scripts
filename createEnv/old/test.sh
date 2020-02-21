#bin/bash
#
# Create DEV environment
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

confFile=/etc/nginx/conf.d/sites.conf
newPool=/etc/php-fpm.d/$site-php-fpm.conf
dataDir=/data
templates=$dataDir/tools/templates
phpTemplate=$templates/php-fpm_template.conf
envDir=$dataDir/envs
httpdConf=$envDir/$devEnv/httpd
httpdLogs=$dataDir/logs/httpd/$site
sitesDir=$envDir/$devEnv/sites
sitePath=$sitesDir/$siteName
siteDocRoot=$sitesDir/$siteName/public_html
user=nginx

if [ ! -d "$httpdConf" ]; then
  mkdir -p $httpdConf
  echo "include $httpdConf/*.conf;" >> $confFile
fi


mkdir -p $httpdLogs

mkdir -p $sitePath/tmp
mkdir -p $sitePath/cache
mkdir -p $sitePath/logs
mkdir -p $siteDocRoot

cp $templates/httpd_template.conf $httpdConf/$siteName.conf

# Personalizar template HTTP
access_log=$httpdLogs/$site-access.log
error_log=$httpdLogs/$site-error.log

sed -i "s@localhost@$server_name@g" $httpdConf/$siteName.conf
sed -i "s@doc_root@$siteDocRoot@g" $httpdConf/$siteName.conf
sed -i "s@accessLog@$access_log@g" $httpdConf/$siteName.conf
sed -i "s@errorLog@$error_log@g" $httpdConf/$siteName.conf
sed -i "s@php_socket@$site@g" $httpdConf/$siteName.conf

# Personalizar template PHP
phpConf=$(sed "s/site-name/$site/g" $phpTemplate)
phpConf=$(sed "s/site-socket/$site/g" <<< "$phpConf")
phpConf=$(sed "s@www-error@$httpdLogs/$site-php-fpm-error.log@g" <<< "$phpConf")
phpConf=$(sed "s@base-dir@$sitePath@g" <<< "$phpConf")
phpConf=$(sed "s@doc-root@$sitePath/public_html@g" <<< "$phpConf")
phpConf=$(sed "s@tmp-dir@$sitePath/tmp@g" <<< "$phpConf")

# Creamos el pool de PHP
echo "$phpConf" >> $newPool

# Apliamos permisos

chown -R $SUDO_USER $sitePath
chown -R $SUDO_USER $httpdConf
chown $user $sitePath/tmp
chown $user $sitePath/cache
chown $user $sitePath/logs

# Aplicamos SELinux context
restorecon -R /data/envs

# Reiniciamos servicios
systemctl reload php-fpm.service
systemctl reload nginx

