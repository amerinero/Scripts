#!/usr/bin/bash
#
# Script pensado para correr el ultimo dia de cada mes.
#   Concatenara el sar -A de todos los ficheros sar de ese mes.
#
# Configuracion
#
BASEDIR=/local3/rendimiento/gcapacidad
LOGFILE=$BASEDIR/log/Recollect.log
ERRORLOG=$BASEDIR/log/errorsRecollect.log

if [ $1 ]
then
        MAQ=$1
else
        echo "Falta servidor"
        echo "$0 servidor <inicio(00:00:00)> <fin(23:59:59)>"
        exit 1
fi 

if [ $2 ]
then
        INICIO=$2
else
	INICIO="00:00:00"
fi

if [ $3 ]
then
        FIN=$3
else
        FIN="23:59:59"
fi


# 
# Este script esta pensado para ser ejecutado el ultimo dia de cada mes.
# Recogera los datos del sar desde el dia 1 del mes en curso hasta el dia en que se ejecute.
#
ULTIMO=`date +%d`

#
# Comenzamos el proceso...
#

INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
echo "$INST_TIME - Comenzamos proceso de extraccion de datos para $MAQ ..." >> $LOGFILE


MESANIO=`/usr/bin/date +%m%Y`
ANIO=`/usr/bin/date +%Y`
TIMESTAMP=`/usr/bin/date +%Y%m%d%H%M%S`
PERIODO=`echo "${INICIO}_to_${FIN}" | sed -e 's/://g'`
CPUMEMFILE=cpumem-$PERIODO-$MAQ-$MESANIO.sar
SSH_CMD="/usr/bin/ssh -o Batchmode=yes -q "
GAP=1800
DATADIR=$BASEDIR/data/mensual
SysOP=`$SSH_CMD ieci@$MAQ uname`
case "$SysOP" in
	Linux)
		FILEPATH="/var/log/sysstat/sa"
		;;
	SunOS)
		FILEPATH="/var/adm/sa/sa"
                ;;
        *)
                echo "Sistema operativo no valido, valores posibles: linux o solaris"
                exit 1
                ;;
esac


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

OUTLIST="$CPUMEMFILE"
for file in $OUTLIST
do 
	if [ -f $file ]
	then
		mv $file $file.$TIMESTAMP
	fi
done

#
# Concatenamos todos los sar desde el dia 1 hasta el actual
# para los datos de cpu y memoria primero, y despues para una seleccion de los discos
# Para historicos el GAP es mucho mayor.
#
for (( dia=1; dia<=$((10#$ULTIMO)); dia++ ))
do
	PADDIA=`printf "%02d" $dia`
	SARFILE=`echo ${FILEPATH}${PADDIA}`
	$SSH_CMD ieci@$MAQ sar -ru -s $INICIO -e $FIN -i $GAP -f $SARFILE >> $CPUMEMFILE 2> $ERRORLOG
done
