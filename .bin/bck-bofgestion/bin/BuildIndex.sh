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
                        ;;
                mensual)
			DATADIR=$BASEDIR/data/mensual
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
echo "<HTML>" > index.html
echo "<TITLE>AST Gestion de la capacidad. Datos Mensuales.</TITLE>" >> index.html
echo "<BODY>" >> index.html

echo "<CENTER><H2>AST Gestion de la capacidad. Datos Mensuales.</H2></CENTER>" >> index.html
echo "<P>" >> index.html
echo "<H3>Servidores analizados:</H3>" >> index.html
echo "<UL>" >> index.html

LISTASERVS=`find . -type d | sed -e 1d -e 's/\.\///g' | sort`
for serv in $LISTASERVS
do
	echo "   <LI><A HREF=\"$serv/index.html\"><H4>$serv</H4></A>" >> index.html
done

echo "</UL>" >> index.html	
echo "</HTML>" >> index.html
