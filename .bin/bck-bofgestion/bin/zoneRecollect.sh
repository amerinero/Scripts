#!/usr/bin/bash
#
# Script pensado para recoger los datos de CPU y memoria de cada zona.
# 
# Busca los ficheros generados dentro de /var/tmp/cpuzones/ y los trae a bof-gestion1
# 
# Nomenclatura de los ficheros de datos esperada: /var/tmp/cpuzones/cpumem-ZONA-MESANIO.csv
#
# Configuracion
#
BASEDIR=/local3/rendimiento/gcapacidad
LOGFILE=$BASEDIR/log/zoneRecollect.log
ERRORLOG=$BASEDIR/log/errorszoneRecollect.log

if [ $1 ]
then
        MAQ=$1
else
        echo "Falta servidor"
        echo "$0 servidor"
        exit 1
fi 

#
# Comenzamos el proceso...
#

INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
echo "$INST_TIME - Comenzamos proceso de recoleccion de datos de zonas para $MAQ ..." >> $LOGFILE

MESANIO=`/usr/bin/date +%m%Y`
TIMESTAMP=`/usr/bin/date +%Y%m%d%H%M%S`
SSH_CMD="/usr/bin/ssh -o Batchmode=yes -q "
SCP_CMD="/usr/bin/scp -o Batchmode=yes -q "
DATADIR=$BASEDIR/data/zonas
REMOTEDIR=/var/tmp/cpuzones
REMOTEFILEP="cpumem-*$MESANIO.csv"


cd $DATADIR

#
# Creamos el directorio para este servidor
#
if [ -d $MAQ ]
then
	cd $MAQ
else 
	mkdir $MAQ
	cd $MAQ
fi

#
# Copiamos todos los ficheros que encontremos en el servidor
# No sabemos que zonas estaran corriendo en cada servidor por que se un cluster.
#
$SCP_CMD ieci@$MAQ:$REMOTEDIR/$REMOTEFILEP . 

INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
echo "$INST_TIME - Proceso de recoleccion de datos de zonas para $MAQ finalizado." >> $LOGFILE
