#!/bin/bash
DIA=`date +%Y%m%d`
if [ $1 ];
then 
	DESTINO=$1
else 
	echo "Error: Necesito saber al menos el destino. user@host."
	exit 1
fi
if [ $2 ];
then
	CLAVE=$2
	COMANDO="gnome-terminal --window-with-profile=cliente -x script -a -f -q -c \"ssh -i $CLAVE $DESTINO\" $HOME/.termlogs/newtermcli_${DIA}_${DESTINO}.log"
else
	COMANDO="gnome-terminal --window-with-profile=cliente -x script -a -f -q -c \"ssh $DESTINO\" $HOME/.termlogs/${DIA}_${DESTINO}.log"

fi
echo "Ejecutandpo: $COMANDO"
eval ${COMANDO}
