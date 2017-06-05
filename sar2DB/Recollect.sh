#!/bin/bash
#set -x
function initdatabase () {
	sqlite3 $1.db "CREATE TABLE SYSDATA (Fecha DATE, Sysname VARCHA(30), Device VARCHAR(20), Parameter VARCHAR(20), Value REAL);"
	echo "$1.db inicializada..."
}
LISTA=lista-servs
while read myLine
do
	SERV=`echo $myLine | awk '{print $1}'`
	SO=`echo $myLine | awk '{print $2}'`
	FILTROAWK=sar${SO}2DB.awk
	echo "SERVIDOR=$SERV, SO=$SO, FiltroAWK=$FILTROAWK"
	if [ ! -f ${SERV}.db ]
	then
		initdatabase $SERV
	fi
	ssh $SERV "LC_ALL=C; export LC_ALL; sar -A" < /dev/null | awk -f $FILTROAWK | sqlite3 ${SERV}.db
done < ${LISTA}
