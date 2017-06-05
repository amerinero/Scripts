#!/usr/bin/bash
#
# entre las muestras (GAP=3h). En el modo mensual es de 30 minutos.
#
# Configuracion
#
BASEDIR=/local3/rendimiento/gcapacidad
LOGFILE=$BASEDIR/log/buildhtml.log
ERRORLOG=$BASEDIR/log/errorsbuildhtml.log
MESANIO=`/usr/bin/date +%m%Y`
OUTHTMLFILE=index.html

if [ $1 ]
then
        serv=$1
else
        echo "Falta Servidor"
        echo "$0 serv. periodo(hist/mensual)"
        exit 1
fi

if [ $2 ]
then
        case "$2" in
                hist)
			DATADIR=$BASEDIR/data/historico
			TABLAS="cpumem diskuse_avserv diskuse_blocks diskuse_busy"
			FILEPAT=hist-$serv
			JPGFILEPAT=HIST-$serv
                        ;;
                mensual)
			DATADIR=$BASEDIR/data/mensual
			TABLAS="cpumem filesystems diskuse_avserv diskuse_blocks diskuse_busy"
			FILEPAT=$serv-$MESANIO
			JPGFILEPAT=$serv-$MESANIO
                        ;;
                *)
                        echo "Periodo no valido, valores posibles: hist o mensual"
                        exit 1
                        ;;
        esac
else
        echo "Falta Periodo..."
        echo "$0 serv. periodo(hist/mensual)"
        exit 1
fi

cd $DATADIR
cd $DATADIR/$serv
echo "<HTML>" > $OUTHTMLFILE
echo "<TITLE>$serv</TITLE>" >> $OUTHTMLFILE
echo "<BODY>" >> $OUTHTMLFILE

echo "<CENTER><H2>$serv</H2></CENTER>" >> $OUTHTMLFILE

echo "<H3>Graficas</H3>" >> $OUTHTMLFILE
for imagen in `ls -1 ${JPGFILEPAT}*.jpg`
do
	echo "   <IMG SRC=\"$imagen\">" >> $OUTHTMLFILE
done

echo "<H3>Tablas de datos</H3>" >> $OUTHTMLFILE
echo "<UL>" >> $OUTHTMLFILE
for tab in $TABLAS
do
	/usr/bin/nawk -v "CSVFILE=$tab-$FILEPAT.csv" -f $BASEDIR/bin/csv2html.awk $tab-$FILEPAT.csv > $tab-$FILEPAT.html
	echo "   <LI><A HREF=\"$tab-$FILEPAT.html\"><H4>$tab</H4></A>" >> $OUTHTMLFILE
done
echo "</UL>" >> $OUTHTMLFILE

echo "</HTML>" >> $OUTHTMLFILE

