#!/usr/bin/bash
#
# Script para lanzar en paralelo varias instancias del script Recollect.sh
# Dado que estamos trabajando sobre bof-gestion1 que tiene 128 procesadores virtuales
# es mejor lanzar una instancia de Recolect.sh por cada servidor en paralelo, reduce
# mucho el tiempo total de ejecucion. 

# Como primer parametro, necesitamos indicarle un fichero con la lista de servidores
# Ver: /local3/rendimiento/gcapacidad/etc/lista-todas-fisicas-solaris
# Ver: /local3/rendimiento/gcapacidad/etc/lista-todas-fisicas-linux
#
# Configuracion
#
BASEDIR=/local3/rendimiento/gcapacidad
LOGFILE=$BASEDIR/log/Recollect.log
ERRORLOG=$BASEDIR/log/errorsRecollect.log

if [ $1 ]
then
        LISTFILE=$1
else
        echo "Falta fichero con la lista de servidores a analizar"
        echo "$0 fichero_list tipo(solaris/linux) periodo(hist/mensual)"
        exit 1
fi

if [ $2 ]
then
        TIPO=$2
else
        echo "Falta tipo de servidor"
        echo "$0 fichero_list tipo(solaris/linux) periodo(hist/mensual)"
        exit 1
fi

if [ $3 ]
then
        PERIODO=$3
else
        echo "Falta periodo "
        echo "$0 fichero_list tipo(solaris/linux) periodo(hist/mensual)"
        exit 1
fi

SERVERLIST=`cat $LISTFILE`

INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
echo "$INST_TIME - Comenzando proceso de recoleccion en paralelo ..." >> $LOGFILE

#
# Por problemas de quedarnos sin memoria hemos visto que no es posible lanzar todas
# las instancias a la vez. Asi que lanzamos un maximo de $MAXLAUNCH, esperamos un minuto y 
# lanzamos otra secuencia de $MAXLAUNCH instancias.
#
MAXLAUNCH=20
CNT=0
for MAQ in $SERVERLIST
do
        $BASEDIR/bin/Recollect.sh $MAQ $TIPO $PERIODO &
        pid=$!
        LISTAPIDS=`echo "$LISTAPIDS $pid"`
	CNT=$(($CNT + 1))
	if [ $CNT -eq $MAXLAUNCH ]
	then
		CNT=0
		sleep 60
	fi
done
INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
echo "$INST_TIME - Lista PIDs lanzados: $LISTAPIDS" >> $LOGFILE
#
# Esperamos hasta que acaben todos los procesos lanzados
#
wait $LISTAPIDS

$BASEDIR/bin/BuildIndex.sh $PERIODO

INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
echo "$INST_TIME - Finalizado proceso de recoleccion en paralelo." >> $LOGFILE
exit 0
