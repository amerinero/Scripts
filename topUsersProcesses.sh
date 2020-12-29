#!/bin/sh
#
# Script para obtener los usuarios que mas CPU consumen y 
# los procesos que mรกs CPU consumen.
# Pensado para ejecutarlos cada X tiempo desde el cron o
# cuando otro proceso lo solicite.
# Por cada ejecuciรณn genera una nueva linea en 
# /var/tmp/informes_TME/info_procesos.
#
#set -x
# Def. Vars.
TIMESTAMP=`date +'%Y%m%d-%H:%M'`
OUTFILE=/var/tmp/informes_TME/info_procesos

#
# Sacamos la lista con los 5 usuarios que mรกs consumen
#
TOPUSERS=`prstat -t  -n 5  1 1 | sed -e 's/\// /g' | head -6 | tail -5 | awk '{LISTA_USERS=LISTA_USERS $2 ","} END {print LISTA_USERS}`

#
# Sacamos la lista con los 5 procesos que m\341s consumen
#
TOPPROCS=`prstat  -n 5  1 1 | sed -e 's/\// /g' | head -6 | tail -5 | awk '{LISTA_PROCS=LISTA_PROCS $10 ","} END {print LISTA_PROCS} '`

echo "$HOSTNAME $TIMESTAMP $TOPUSERS    $TOPPROCS"  >> $OUTFILE
