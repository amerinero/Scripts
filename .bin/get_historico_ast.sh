#!/bin/bash
DATADIR=/var/www/AST/stats/historico
RUSER=ieci
FILEP=hist
RFILE=/local3/rendimiento/gcapacidad/data/historico/$FILEP.tar.gz
RSERVER=bof-gestion1
cd $DATADIR
if [ -f $FILEP.tar ] 
then
	rm $FILEP.tar
fi
if [ -f $FILEP.tar.gz ]
then
        rm $FILEP.tar.gz
fi

scp $RUSER@$RSERVER:$RFILE . > /dev/null 2>&1
gunzip $FILEP.tar.gz > /dev/null 2>&1
tar xf $FILEP.tar > /dev/null 2>&1
