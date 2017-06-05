#!/usr/bin/bash
#
#
# Configuracion
#
BASEDIR=/local3/rendimiento/gcapacidad
LOGFILE=$BASEDIR/log/buildhtml.log
ERRORLOG=$BASEDIR/log/errorsbuildhtml.log
MESANIO=`/usr/bin/date +%m%Y`
DATADIR=$BASEDIR/informes

cd $DATADIR
rm index.html
LISTA=`ls -1 *.html | sort`
echo "<HTML>" > index.html
echo "<TITLE>AST Gestion de la capacidad. Informes.</TITLE>" >> index.html
echo "<BODY>" >> index.html

echo "<CENTER><H2>AST Gestion de la capacidad. Informes.</H2></CENTER>" >> index.html
echo "<P>" >> index.html
echo "<UL>" >> index.html

for info in $LISTA
do
	NOMBRE=`echo $info | sed -e 's/\.html//g'`
	echo "   <LI><A HREF=\"$info\"><H4>$NOMBRE</H4></A>" >> index.html
done

echo "</UL>" >> index.html	
echo "</HTML>" >> index.html
