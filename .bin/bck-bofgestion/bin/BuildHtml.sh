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

if [ $1 ]
then
        case "$1" in
                hist)
			DATADIR=$BASEDIR/data/historico
			TABLAS="cpumem diskuse_avserv diskuse_blocks diskuse_busy"
                        ;;
                mensual)
			DATADIR=$BASEDIR/data/mensual
			TABLAS="cpumem filesystems diskuse_avserv diskuse_blocks diskuse_busy"
                        ;;
                *)
                        echo "Periodo no valido, valores posibles: hist o mensual"
                        exit 1
                        ;;
        esac
else
        echo "Falta Periodo..."
        echo "$0 periodo(hist/mensual)"
        exit 1
fi

cd $DATADIR
LISTASERVS=`find . -type d | sed -e 1d -e 's/\.\///g' | sort`
for serv in $LISTASERVS
do
	cd $DATADIR/$serv
	echo "<HTML>" > index.html
	echo "<TITLE>$serv</TITLE>" >> index.html
	echo "<BODY>" >> index.html

	echo "<CENTER><H2>$serv</H2></CENTER>" >> index.html

	echo "<H3>Graficas</H3>" >> index.html
	for imagen in `ls -1 *.jpg`
	do
		echo "   <IMG SRC=\"$imagen\">" >> index.html
	done

	echo "<H3>Tablas de datos</H3>" >> index.html
	case "$1" in
		hist)
			FILEPAT=hist-$serv
			;;
		mensual)
			FILEPAT=$serv-$MESANIO
			;;	
	esac
	echo "<UL>" >> index.html
	for tab in $TABLAS
	do
		/usr/bin/nawk -f $BASEDIR/bin/csv2html.awk $tab-$FILEPAT.csv > $tab-$FILEPAT.html
		echo "   <LI><A HREF=\"$tab-$FILEPAT.html\"><H4>$tab</H4></A>" >> index.html
	done
	echo "</UL>" >> index.html	

	echo "</HTML>" >> index.html
done

