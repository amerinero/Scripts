#!/usr/bin/bash
#
# Script para generar el informe con las medias mensuales de consumo de memoria y CPU en las zonas de pool-z.
# El script utiliza los datos que haya en data/zonas/serv/cpumem-*.csv
#
# El informe consta de dos medias de CPU y dos de memoria. Una en el intervalo 00:00 a 08:00 y
# otra en el intervalo 08:00 a 23:59
# 
# Configuracion
#
BASEDIR=/local3/rendimiento/gcapacidad
LOGFILE=$BASEDIR/log/zonasmediaCPUMEM.log
ERRORLOG=$BASEDIR/log/errorszonasmediaCPUMEM.log
TIMESTAMP=`/usr/bin/date +%Y%m%d%H%M%S`
export LC_ALL=es_ES
DATADIR=$BASEDIR/data/zonas
INFODIR=$BASEDIR/informes
MESANIO=`/usr/bin/date +%m%Y`
OUTFILE=$BASEDIR/informes/zonasmediaCPUMEN-$MESANIO.csv
OUTNAME=zonasmediaCPUMEN-$MESANIO.csv
OUTFILEHTML=$BASEDIR/informes/zonasmediaCPUMEN-$MESANIO.html
if [ -f $OUTFILE ]
then
	mv $OUTFILE $OUTFILE.$TIMESTAMP
fi


/usr/bin/echo "Servidor;Zona;CPU 00:00-08:00;Memoria 00:00-08:00;CPU 08:00-23:59;Memoria 08:00-23:59" > $OUTFILE
cd $DATADIR
LISTASERVS=`find . -type d | sed -e 1d -e 's/\.\///g' | sort`
INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
echo "$INST_TIME - Inicio calculo de medias de de CPU y memoria para las zonas..." >> $LOGFILE
for serv in $LISTASERVS
do	
	INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
	echo "$INST_TIME - Calculando para $serv ..." >> $LOGFILE
	ZONEFILES=`/usr/bin/ls -1 $serv/cpumem*$MESANIO.csv`
	PSERV=$serv
	for zonef in $ZONEFILES
	do
		ZONA=`echo "$zonef" | sed -e "s/$serv\/cpumem-//g" -e "s/-${MESANIO}.csv//g"`
		INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
		echo "$INST_TIME - Calculando para $ZONA ..." >> $LOGFILE
		MEDIA1=`egrep ' 0[01234567]:' $zonef | /usr/bin/nawk -f $BASEDIR/bin/media_zonasCPUMEN.awk`
		MEDIA2=`egrep ' 0[89]:| 1[0123456789]:| 2[0123]:' $zonef | /usr/bin/nawk -f $BASEDIR/bin/media_zonasCPUMEN.awk`
		/usr/bin/echo "$PSERV;$ZONA;$MEDIA1;$MEDIA2" >> $OUTFILE
		PSERV=""
	done
done
/usr/bin/nawk -v "CSVFILE=$OUTNAME" -f $BASEDIR/bin/csv2html.awk $OUTFILE > $OUTFILEHTML
INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
echo "$INST_TIME - Calculo de medias de de CPU y memoria terminado." >> $LOGFILE
