#!/usr/bin/bash
#
# Script para generar el informe informes/alertaocupacion-filesystems-$MESANIO.csv
# Reporta los filesystems con una ocupacion superior al 85%
# Utiliza el filtro filesystemsfull.awk
# 
# Configuracion
#
BASEDIR=/local3/rendimiento/gcapacidad
LOGFILE=$BASEDIR/log/infofilesystems.log
ERRORLOG=$BASEDIR/log/errorsinfofilesystems.log
TIMESTAMP=`/usr/bin/date +%Y%m%d%H%M%S`

DATADIR=$BASEDIR/data/mensual
INFODIR=$BASEDIR/informes
MESANIO=`/usr/bin/date +%m%Y`
OUTFILE=$BASEDIR/informes/alertaocupacion-filesystems-$MESANIO.csv
OUTNAME=alertaocupacion-filesystems-$MESANIO.csv
OUTFILEHTML=$BASEDIR/informes/alertaocupacion-filesystems-$MESANIO.html
SSH_CMD="/usr/bin/ssh -o Batchmode=yes -q "
if [ -f $OUTFILE ]
then
        mv $OUTFILE $OUTFILE.$TIMESTAMP
fi

/usr/bin/echo "Servidor;Filesystem;% Ocupacion" > $OUTFILE
cd $DATADIR
LISTASERVS=`find . -type d | sed -e 1d -e 's/\.\///g' | sort`
INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
echo "$INST_TIME - Buscando filesystems altamente ocupados..." >> $LOGFILE
for serv in $LISTASERVS
do
	INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
	echo "$INST_TIME - Buscando en $serv ..." >> $LOGFILE
	DATAFILE=$serv/filesystems-$serv-$MESANIO.csv
	export LC_ALL=es_ES
	/usr/bin/nawk -v "SERV=$serv" -f $BASEDIR/bin/filesystemsfull.awk $DATAFILE >> $OUTFILE
done
/usr/bin/nawk -v "CSVFILE=$OUTNAME" -f $BASEDIR/bin/csv2html.awk $OUTFILE > $OUTFILEHTML
INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
echo "$INST_TIME - Busqueda de filesystems altamente ocupados terminada." >> $LOGFILE
