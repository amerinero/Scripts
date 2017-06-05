#!/bin/bash
#
# Vamos al directorio de zonas y asumimos que cada direcctorio es un servidor con zonas
#
ZONESDIR=/var/www/AST/stats/zonas
MESANIO=`date +%m%Y`

cd $ZONESDIR

echo "<HTML>" > index.html
echo "<TITLE>Servidores con Zonas</TITLE>" >> index.html
echo "<BODY>" >> index.html
echo "<CENTER><H2>Servidores con Zonas</H2></CENTER>" >> index.html
echo "<UL>" >> index.html

for SERV in `find . -type d | sed -e 1d -e 's/\.\///g' | sort`
do
	echo "<LI><A HREF=\"$SERV/index.html\"><H4>$SERV</H4></A>" >> index.html
	cd $SERV

	echo "<HTML>" > index.html
	echo "<TITLE>$SERV</TITLE>" >> index.html 
	echo "<BODY>" >> index.html
	echo "<CENTER><H2>$SERV</H2></CENTER>" >> index.html
	echo "<H3>Graficas</H3>" >> index.html
	echo "<IMG SRC=\"$SERV-$MESANIO.jpg\">" >> index.html
	
	cat /var/www/.bin/preplot1.txt > $SERV.gnuplot

	# Por cada fichero de datos 1er plot
	Nele=`ls -1 cpumem*$MESANIO.csv | wc -l`
	CNT=1
	for FILE in `ls -1 cpumem*$MESANIO.csv`
	do	
		ZONENAME=`echo $FILE | awk -F- '{print $2'}`
		sed -e 1d -e 's/ CEST 2010//g' -e 's/^....//g' $FILE > plot-$FILE
		if [ $CNT -eq $Nele ]; then TAIL=""; else  TAIL=",\\";  fi
		echo "'plot-$FILE' using 1:3 smooth csplines notitle$TAIL"  >> $SERV.gnuplot
		CNT=$(( $CNT + 1 ))
	done 

	cat /var/www/.bin/preplot2.txt >> $SERV.gnuplot
	# Segundo Plot
	Nele=`ls -1 cpumem*$MESANIO.csv | wc -l`
        CNT=1
        for FILE in `ls -1 cpumem*$MESANIO.csv`
        do
                ZONENAME=`echo $FILE | awk -F- '{print $2'}`
                sed -e 1d -e 's/ CEST 2010//g' -e 's/^....//g' $FILE > plot-$FILE
                if [ $CNT -eq $Nele ]; then TAIL=""; else  TAIL=",\\";  fi
                echo "'plot-$FILE' using 1:2 smooth csplines  title \"$ZONENAME\"$TAIL" >> $SERV.gnuplot
                CNT=$(( $CNT + 1 ))
        done
	
	/usr/bin/gnuplot $SERV.gnuplot > $SERV-$MESANIO.jpg

	echo "</HTML>" >> index.html
	cd ..
done
echo "</UL>" >> index.html
echo "</HTML>" >> index.html
