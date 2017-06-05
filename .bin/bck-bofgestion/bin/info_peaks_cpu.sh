#!/usr/bin/bash
#
# Script para generar el informe informes/alerta-cpu-$MESANIO.csv
# Reporta los picos de ocupacion de CPU mayores al 80%
# Utiliza el filtro peakscpu.awk
# 
# Configuracion
#
BASEDIR=/local3/rendimiento/gcapacidad
LOGFILE=$BASEDIR/log/infopeakscpu.log
ERRORLOG=$BASEDIR/log/errorsinfopeakscpu.log
TIMESTAMP=`/usr/bin/date +%Y%m%d%H%M%S`

DATADIR=$BASEDIR/data/mensual
INFODIR=$BASEDIR/informes
MESANIO=`/usr/bin/date +%m%Y`
OUTFILE=$BASEDIR/informes/alerta-cpu-$MESANIO.csv
OUTNAME=alerta-cpu-$MESANIO.csv
OUTFILEHTML=$BASEDIR/informes/alerta-cpu-$MESANIO.html
SSH_CMD="/usr/bin/ssh -o Batchmode=yes -q "
if [ -f $OUTFILE ]
then
        mv $OUTFILE $OUTFILE.$TIMESTAMP
fi

/usr/bin/echo "Servidor;Fecha;% Ocupacion CPU" > $OUTFILE
cd $DATADIR
LISTASERVS=`find . -type d | sed -e 1d -e 's/\.\///g' | sort`
INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
echo "$INST_TIME - Buscando picos de cpu..." >> $LOGFILE
for serv in $LISTASERVS
do
	INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
	echo "$INST_TIME - Buscando en $serv ..." >> $LOGFILE
	DATAFILE=$serv/cpumem-$serv-$MESANIO.csv
	export LC_ALL=es_ES
	/usr/bin/nawk -v "SERV=$serv" -f $BASEDIR/bin/peakscpu.awk $DATAFILE >> $OUTFILE
done
/usr/bin/nawk -v "CSVFILE=$OUTNAME" -f $BASEDIR/bin/csv2html.awk $OUTFILE > $OUTFILEHTML
INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
echo "$INST_TIME - Busqueda de picos de cpu terminada." >> $LOGFILE
