#!/bin/bash
DIA=`date +%Y%m%d`
if [ $1 ];
then
	DESTINO=$@
else
	echo "Error: Necesito saber al menos el destino. user@host."
	exit 1
fi
read arg1 arg2 arg3 <<< "$DESTINO"
if  [ -z $arg3 ]
then 
	USERIP=$arg1
else
	USERIP=$arg3
fi
COMANDO="gnome-terminal --window-with-profile=cliente -x script -a -f -q -c \"ssh $DESTINO\" $HOME/.termlogs/${DIA}_${USERIP}.log"

#if [ $2 ];
#then
#	CLAVE=$2
#	COMANDO="gnome-terminal --window-with-profile=cliente -x script -a -f -q -c \"ssh -i $CLAVE $DESTINO\" $HOME/.termlogs/newtermcli_${DIA}_${DESTINO}.log"
#else
#	COMANDO="gnome-terminal --window-with-profile=cliente -x script -a -f -q -c \"ssh $DESTINO\" $HOME/.termlogs/${DIA}_${DESTINO}.log"

#fi
echo "Ejecutando: $COMANDO"
eval ${COMANDO}
