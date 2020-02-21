# Author: Miguel Perdices
#
# Version: 0.9 (Apr 2018)
#

site=$1
config="$2"

newSite=/etc/php-fpm.d/$site-php-fpm.conf
echo "$config" >> $newSite

systemctl restart php-fpm.service
