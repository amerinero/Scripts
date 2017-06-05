#!/usr/bin/bash
#
# Script para generar el informe con las medias mensuales de consumo de memoria y CPU.
# El script utiliza los datos que haya en data/mensual/serv/cpumem-agregado....
#
# El informe consta de dos medias de CPU y dos de memoria. Una en el intervalo 00:00 a 08:00 y
# otra en el intervalo 08:00 a 23:59
# 
# Configuracion
#
BASEDIR=/local3/rendimiento/gcapacidad
LOGFILE=$BASEDIR/log/mediaCPUMEM.log
ERRORLOG=$BASEDIR/log/errorsmediaCPUMEM.log

DATADIR=$BASEDIR/data/historico-solomarzo
INFODIR=$BASEDIR/informes
MESANIO=`/usr/bin/date +%m%Y`
OUTFILE=$BASEDIR/informes/mediaCPUMEN-032010.csv
SSH_CMD="/usr/bin/ssh -o Batchmode=yes -q "
PAGEMEMFILE=$BASEDIR/etc/solaris_servers-pagesize-memsize.dat

/usr/bin/echo "Servidor;CPU 00:00-08:00;Memoria 00:00-08:00;CPU 08:00-23:59;Memoria 08:00-23:59" > $OUTFILE
cd $DATADIR
LISTASERVS=`find . -type d | sed -e 1d -e 's/\.\///g' | sort`
INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
echo "$INST_TIME - Inicio calculo de medias de de CPU y memoria..." >> $LOGFILE
for serv in $LISTASERVS
do
	INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
	echo "$INST_TIME - Calculando para $serv ..." >> $LOGFILE
	DATAFILE=$serv/cpumem-hist-$serv.sar
	TIPO=`head -1 $DATAFILE | awk '{print $1}'`
	export LC_ALL=es_ES
	if [ "$TIPO" == "Linux" ]
	then
		MEDIA1=`egrep '^0[1234567]' $DATAFILE | /usr/bin/nawk -f $BASEDIR/bin/media_linuxCPUMEM.awk`
		MEDIA2=`egrep '^0[89]|^1[0123456789]|^2[0123]' $DATAFILE | grep -v kbmemfree | grep -v steal | /usr/bin/nawk -f $BASEDIR/bin/media_linuxCPUMEM.awk`
	else
		MEMSIZE=`grep $serv $PAGEMEMFILE | awk '{print $3}'`
		PAGESIZE=`grep $serv $PAGEMEMFILE | awk '{print $2}'`
		MEDIA1=`egrep '^0[1234567]' $DATAFILE | /usr/bin/nawk -v "PAGE=$PAGESIZE" -v "MEMS=$MEMSIZE" -f $BASEDIR/bin/media_solarisCPUMEM.awk`
		MEDIA2=`egrep '^0[89]|^1[0123456789]|^2[0123]' $DATAFILE | /usr/bin/nawk -v "PAGE=$PAGESIZE" -v "MEMS=$MEMSIZE" -f $BASEDIR/bin/media_solarisCPUMEM.awk`
	fi
	export LC_ALL=C
	/usr/bin/echo "$serv;$MEDIA1;$MEDIA2" >> $OUTFILE
done
INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
echo "$INST_TIME - Calculo de medias de de CPU y memoria terminado." >> $LOGFILE
