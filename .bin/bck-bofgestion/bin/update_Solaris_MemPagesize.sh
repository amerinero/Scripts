#!/usr/bin/bash
#
# Script para generar una lista con el pagesize y la memoria total de cada servidor solaris
#
# La lista que genera se usa de desde mediaCPUMEM.sh
#
BASEDIR=/local3/rendimiento/gcapacidad
LOGFILE=$BASEDIR/log/update_SolarisPagesize.log
ERRORLOG=$BASEDIR/log/errorsupdate_SolarisPagesize.log
DATADIR=$BASEDIR/etc
SSH_CMD="/usr/bin/ssh -o Batchmode=yes -q "
OUTFILE=$DATADIR/solaris_servers-pagesize-memsize.dat

echo "Servidor Pagesize Memoria(MB)" > $OUTFILE
LISTASERVERS=`cat $BASEDIR/etc/lista-todas-fisicas-solaris`
for serv in $LISTASERVERS
do
	MEMSIZE=`$SSH_CMD ieci@$serv "/usr/sbin/prtconf | grep \"Memory size\"" | awk '{print $3}'`
	PAGESIZE=`$SSH_CMD ieci@$serv "/usr/bin/pagesize"`
	echo "$serv $PAGESIZE $MEMSIZE" >> $OUTFILE
done
