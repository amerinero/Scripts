#!/usr/bin/bash
#
# Script para generar el informe con las medias mensuales de consumo de memoria y CPU.
# El script utiliza los datos que haya en data/mensual/serv/cpumem-serv-MESANIO.csv.
#
# El informe consta de dos medias de CPU y dos de memoria. Una en el intervalo 00:00 a 08:00 y
# otra en el intervalo 08:00 a 23:59
#
# Utiliza el filtro media_CPUMEM.awk para el calculo de las medias
# 
# Configuracion
#
BASEDIR=/local3/rendimiento/gcapacidad
LOGFILE=$BASEDIR/log/mediaCPUMEM.log
ERRORLOG=$BASEDIR/log/errorsmediaCPUMEM.log
TIMESTAMP=`/usr/bin/date +%Y%m%d%H%M%S`

DATADIR=$BASEDIR/data/mensual
INFODIR=$BASEDIR/informes
MESANIO=`/usr/bin/date +%m%Y`
OUTFILE=$BASEDIR/informes/mediaCPUMEN-$MESANIO.csv
OUTNAME=mediaCPUMEN-$MESANIO.csv
OUTFILEHTML=$BASEDIR/informes/mediaCPUMEN-$MESANIO.html
if [ -f $OUTFILE ]
then
        mv $OUTFILE $OUTFILE.$TIMESTAMP
fi

/usr/bin/echo "Servidor;CPU 00:00-08:00;Memoria 00:00-08:00;CPU 08:00-23:59;Memoria 08:00-23:59" > $OUTFILE
cd $DATADIR
LISTASERVS=`find . -type d | sed -e 1d -e 's/\.\///g' | sort`
INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
echo "$INST_TIME - Inicio calculo de medias de de CPU y memoria..." >> $LOGFILE
for serv in $LISTASERVS
do
	INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
	echo "$INST_TIME - Calculando para $serv ..." >> $LOGFILE
	DATAFILE=$serv/cpumem-$serv-$MESANIO.csv
	export LC_ALL=es_ES
	MEDIA1=`egrep ' 0[01234567]:' $DATAFILE | /usr/bin/nawk -f $BASEDIR/bin/media_CPUMEM.awk`
	MEDIA2=`egrep ' 0[89]:| 1[0123456789]:| 2[0123]:' $DATAFILE | /usr/bin/nawk -f $BASEDIR/bin/media_CPUMEM.awk`
	export LC_ALL=C
	/usr/bin/echo "$serv;$MEDIA1;$MEDIA2" >> $OUTFILE
done
/usr/bin/nawk -v "CSVFILE=$OUTNAME" -f $BASEDIR/bin/csv2html.awk $OUTFILE > $OUTFILEHTML
INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
echo "$INST_TIME - Calculo de medias de de CPU y memoria terminado." >> $LOGFILE
