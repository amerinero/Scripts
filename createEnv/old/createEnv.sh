#bin/bash
#
# Create DEV environment
#
# Author: Miguel Perdices
#
# Version: 0.9.2 (May 2018)
#

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 ENV SITE" >&2
  exit 1
fi

devEnv=$1
siteName=$2

site=$devEnv-$siteName

confFile=/etc/nginx/conf.d/sites.conf
dataDir=/data
templates=$dataDir/tools/templates
phpTemplate=$templates/php-fpm_template.conf 
envDir=$dataDir/envs
httpdConf=$envDir/$devEnv/httpd
httpdLogs=$dataDir/logs/httpd/$site
sitesDir=$envDir/$devEnv/sites
sitePath=$sitesDir/$siteName
siteDocRoot=$sitesDir/$siteName/public_html

if [ ! -d "$httpdConf" ]; then
  mkdir -p $httpdConf
  sudo ./enableEnv.sh $httpdConf $confFile
fi

sudo ./enableLogs.sh $httpdLogs

mkdir -p $sitePath/tmp
mkdir -p $sitePath/cache
mkdir -p $sitePath/logs
mkdir -p $siteDocRoot

cp $templates/httpd_template.conf $httpdConf/$site.conf

#Personalizar template HTTP
server_name="$site"
access_log=$httpdLogs/$site-access.log
error_log=$httpdLogs/$site-error.log

sed -i "s@localhost@$server_name@g" $httpdConf/$site.conf
sed -i "s@doc_root@$siteDocRoot@g" $httpdConf/$site.conf
sed -i "s@accessLog@$access_log@g" $httpdConf/$site.conf
sed -i "s@errorLog@$error_log@g" $httpdConf/$site.conf
sed -i "s@php_socket@$site@g" $httpdConf/$site.conf

sudo ./fixPermissions.sh 

#Personalizar template PHP
phpConf=$(sed "s/site-name/$site/g" $phpTemplate)
phpConf=$(sed "s/site-socket/$site/g" <<< "$phpConf")
phpConf=$(sed "s@www-error@$httpdLogs/$site-php-fpm-error.log@g" <<< "$phpConf")
phpConf=$(sed "s@base-dir@$sitePath@g" <<< "$phpConf")
phpConf=$(sed "s@doc-root@$sitePath/public_html@g" <<< "$phpConf")
phpConf=$(sed "s@tmp-dir@$sitePath/tmp@g" <<< "$phpConf")

sudo ./createPool.sh $site "$phpConf"
sudo nginx -s reload
