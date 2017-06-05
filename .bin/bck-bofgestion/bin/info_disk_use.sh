#!/usr/bin/bash
#
# Script para generar el informe mensual/<serv>/diskuse_busy.csv, diskuse_avserv.csv y diskuse_blocks.csv
# Utiliza los filtros busy-devs.awk, avserv-devs.awk y blocks-devs.awk
# 
# Configuracion
#
BASEDIR=/local3/rendimiento/gcapacidad
LOGFILE=$BASEDIR/log/infodiskuse.log
ERRORLOG=$BASEDIR/log/errorsinfodiskuse.log

DATADIR=$BASEDIR/data/mensual
MESANIO=`/usr/bin/date +%m%Y`
ANALISYS="busy avserv blocks"

cd $DATADIR
LISTASERVS=`find . -type d | sed -e 1d -e 's/\.\///g' | sort`
INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
echo "$INST_TIME - Generando CSV's con datos del uso de discos..." >> $LOGFILE
for serv in $LISTASERVS
do
	INFILE=$serv/dev-$serv-$MESANIO.csv
	export LC_ALL=es_ES
	for ana in $ANALISYS
	do
		INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
		echo "$INST_TIME - Generando $ana para $serv ..." >> $LOGFILE
		OUTFILE=$serv/diskuse_$ana-$serv-$MESANIO.csv
		nawk -f $BASEDIR/bin/$ana-devs.awk $INFILE > $OUTFILE
	done
done
INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
echo "$INST_TIME - CSV's con datos de uso de disco generados." >> $LOGFILE
