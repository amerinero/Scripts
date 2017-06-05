#!/usr/bin/bash
#
# Script pensado para correr el ultimo dia de cada mes.
# Concatenara el sar -ru de todos los ficheros sar de ese mes.
# Concatenara el sar -d de todos los ficheros sar de ese mes.
# Genera graficas de CPU y memoria con Ksar.
# Genera ficheros csv con los datos del sar con ksar.
# Genera ficheros csv con los datos del df -k.

# En el modo mensual escribe sobre /local3/rendimiento/gcapacidad/data/mensual
# En el modo hist escribe sobre /local3/rendimiento/gcapacidad/data/historico y
# concatena con los ficheros de historico anteriores. 

# Tanto en modo mensual como historico se trabaja con los datos que se cojen por ssh 
# del sar de cada servidor. En el modo historico se recolectan con mucho mayor separacion temporal
# entre las muestras (GAP=3h). En el modo mensual es de 30 minutos.
#
# Configuracion
#
BASEDIR=/local3/rendimiento/gcapacidad
LOGFILE=$BASEDIR/log/Recollect.log
ERRORLOG=$BASEDIR/log/errorsRecollect.log

if [ $1 ]
then
        MAQ=$1
else
        echo "Falta servidor"
        echo "$0 servidor tipo(solaris/linux) periodo(hist/mensual)"
        exit 1
fi 

if [ $2 ]
then
	case "$2" in
		linux)
			FILEPATH="/var/log/sysstat/sa"
			DEVICEFILTER="'^$'"
			GRAPHLIST="all-cpu LinuxkbmemSar"
			DFCMD="export LC_ALL=C ; df -P -F ext3 -k ; df -P -F ext2 -k"
			;;
		solaris)
			FILEPATH="/var/adm/sa/sa"
			DEVICEFILTER=' sdbc| gsdb| st| ohci| ehci| ramdisk|\.t|,.'
			GRAPHLIST="SolariscpuSar SolarismemSar"
			DFCMD="LC_ALL=C ; export LC_ALL; df -F ufs -k ; df -F zfs -k"
			;;
		*)
			echo "Tipo no valido, valores posibles: linux o solaris"
			exit 1
			;;
	esac
else
        echo "Falta tipo de servidor"
        echo "$0 servidor tipo(solaris/linux) periodo(hist/mensual)"
        exit 1
fi

if [ $3 ]
then
        case "$3" in
                hist)
			DATADIR=$BASEDIR/data/historico
			GAP=10800
                        ;;
                mensual)
			DATADIR=$BASEDIR/data/mensual
			GAP=1800
                        ;;
                *)
                        echo "Periodo no valido, valores posibles: hist o mensual"
                        exit 1
                        ;;
        esac
else
        echo "Falta Periodo..."
        echo "$0 servidor tipo(solaris/linux) periodo(hist/mensual)"
        exit 1
fi

# 
# Este script esta pensado para ser ejecutado el ultimo dia de cada mes.
# Recogera los datos del sar desde el dia 1 del mes en curso hasta el dia en que se ejecute.
#
ULTIMO=`date +%d`

#
# Comenzamos el proceso...
#

INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
echo "$INST_TIME - Comenzamos proceso de extraccion de datos para $MAQ ..." >> $LOGFILE


MESANIO=`/usr/bin/date +%m%Y`
ANIO=`/usr/bin/date +%Y`
TIMESTAMP=`/usr/bin/date +%Y%m%d%H%M%S`
CPUMEMFILE=cpumem-agregado-$MAQ-$MESANIO.sar
CPUMEMHISTFILE=cpumem-hist-$MAQ.sar
DEVFILE=dev-agregado-$MAQ-$MESANIO.sar
DEVHISTFILE=dev-hist-$MAQ.sar
FSOUTFILE=filesystems-$MAQ-$MESANIO.csv
GRAPHOUT=$MAQ-$MESANIO
GRAPHOUTHIST=HIST-$MAQ
CSVCPUMEMOUT=cpumem-$MAQ-$MESANIO.csv
CSVCPUMEMOUTHIST=cpumem-hist-$MAQ.csv
CSVDEVOUT=dev-$MAQ-$MESANIO.csv
CSVDEVOUTHIST=dev-hist-$MAQ.csv
SSH_CMD="/usr/bin/ssh -o Batchmode=yes -q "
GRAPHEXEC="/usr/bin/java -jar $BASEDIR/bin/kSar-5.0.6/kSar.jar"
GRAPHWIDTH=800
GRAPHHEIGHT=600
GRAPHOPTIONS="-cpuFixedAxis -width $GRAPHWIDTH -height $GRAPHHEIGHT"
ANALISYS="busy avserv blocks"

cd $DATADIR

#
# Creamos el directorio para este servidor
#
if [ -d $MAQ ]
then
	cd $MAQ
else 
	mkdir $MAQ
	cd $MAQ
fi

#
# Para no machacar lo que ya tenemos 
#
OUTLIST=`ls -1`
for file in $OUTLIST
do 
	/usr/bin/mv $file $file.$TIMESTAMP
	/usr/bin/gzip $file.$TIMESTAMP
done

#
# Concatenamos todos los sar desde el dia 1 hasta el actual
# para los datos de cpu y memoria primero, y despues para una seleccion de los discos
# Para historicos el GAP es mucho mayor.
#
for (( dia=1; dia<=$((10#$ULTIMO)); dia++ ))
do
	PADDIA=`printf "%02d" $dia`
	SARFILE=`echo ${FILEPATH}${PADDIA}`
	INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
	echo "$INST_TIME - Extrayendo datos de $MAQ $SARFILE ..." >> $LOGFILE
	$SSH_CMD ieci@$MAQ "LC_ALL=C; export LC_ALL; sar -ru -i $GAP -f $SARFILE" >> $CPUMEMFILE 2> $ERRORLOG
	$SSH_CMD ieci@$MAQ "LC_ALL=C; export LC_ALL; sar -d -i $GAP -f $SARFILE" | egrep -v "$DEVICEFILTER" >> $DEVFILE 2> $ERRORLOG
done

#
# Generamos las graficas....
#
case "$3" in
        hist)
		INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
		echo "$INST_TIME - Concatenando datos historicos $MAQ" >> $LOGFILE
		#
		# Concatenamos
		#	
		/usr/bin/cat $CPUMEMHISTFILE $CPUMEMFILE > tmp1file1
		/usr/bin/mv tmp1file1 $CPUMEMHISTFILE
		/usr/bin/cat $DEVHISTFILE $DEVFILE > tmp1file1
		/usr/bin/mv tmp1file1 $DEVHISTFILE
		rm $DEVFILE $CPUMEMFILE
		INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
		echo "$INST_TIME - Generando graficas historicas para $MAQ" >> $LOGFILE
                #
                # Grafica de CPU y Memoria + csv de CPU y Memoria
                #
                $GRAPHEXEC -graph "$GRAPHLIST" $GRAPHOPTIONS -outputJPG $GRAPHOUTHIST -outputCSV tmp-cpu.csv -input $CPUMEMHISTFILE 2> $ERRORLOG
		#
                # Calculamos el % de memoria libre y lo aniadimos al CSV
		# Solo en caso Solaris	
                #
		if [ "$2" == "solaris" ]
		then
			PAGEMEMFILE=$BASEDIR/etc/solaris_servers-pagesize-memsize.dat
			MEMSIZE=`grep $MAQ $PAGEMEMFILE | awk '{print $3}'`
			PAGESIZE=`grep $MAQ $PAGEMEMFILE | awk '{print $2}'`
			/usr/bin/nawk -v "PAGE=$PAGESIZE" -v "MEMS=$MEMSIZE" -f $BASEDIR/bin/percentMEMFree.awk tmp-cpu.csv > tmp2-cpu.csv
			/usr/bin/nawk '{gsub("\\.",",",$0);print $0}' tmp2-cpu.csv > ${CSVCPUMEMOUTHIST}
			rm tmp2-cpu.csv
		else 
			/usr/bin/nawk '{gsub("\\.",",",$0);print $0}' tmp-cpu.csv > ${CSVCPUMEMOUTHIST}
		fi
                #
                # CSV de discos
                #
                $GRAPHEXEC -outputCSV tmp-dev.csv -input $DEVHISTFILE 2>> $ERRORLOG
		/usr/bin/nawk '{gsub("\\.",",",$0);print $0}' tmp-dev.csv > ${CSVDEVOUTHIST}
		rm tmp-cpu.csv
		rm tmp-dev.csv
		#
                # Con el CSV de los discos generamos otros tres con el %busy, blocks/s y avservt
                #
		for ana in $ANALISYS
	        do
                	INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
                	echo "$INST_TIME - Generando $ana para $MAQ ..." >> $LOGFILE
        	        ANA_OUTFILE=diskuse_$ana-hist-$MAQ.csv
               		LC_ALL=es_ES; /usr/bin/nawk -f $BASEDIR/bin/$ana-devs.awk ${CSVDEVOUTHIST}  > $ANA_OUTFILE; LC_ALL=C
       		done
                ;;
	mensual)
                INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
                echo "$INST_TIME - Generando graficas mensuales para $MAQ" >> $LOGFILE

		$GRAPHEXEC -graph "$GRAPHLIST" $GRAPHOPTIONS -outputJPG $GRAPHOUT -outputCSV tmp-cpu.csv -input $CPUMEMFILE 2> $ERRORLOG
                #
                # Calculamos el % de memoria libre y lo añadimos al CSV
		# Solo en caso solaris
                #
		if [ $2 == "solaris" ]
		then
                	PAGEMEMFILE=$BASEDIR/etc/solaris_servers-pagesize-memsize.dat
                	MEMSIZE=`grep $MAQ $PAGEMEMFILE | awk '{print $3}'`
                	PAGESIZE=`grep $MAQ $PAGEMEMFILE | awk '{print $2}'`
                	/usr/bin/nawk -v "PAGE=$PAGESIZE" -v "MEMS=$MEMSIZE" -f $BASEDIR/bin/percentMEMFree.awk tmp-cpu.csv > tmp2-cpu.csv
                        /usr/bin/nawk '{gsub("\\.",",",$0);print $0}' tmp2-cpu.csv > $CSVCPUMEMOUT
                        rm tmp2-cpu.csv
                else
                        /usr/bin/nawk '{gsub("\\.",",",$0);print $0}' tmp-cpu.csv > $CSVCPUMEMOUT
                fi
                #
                # CSV de discos
                #
		$GRAPHEXEC -outputCSV tmp-dev.csv -input $DEVFILE 2>> $ERRORLOG
		/usr/bin/nawk '{gsub("\\.",",",$0);print $0}' tmp-dev.csv > $CSVDEVOUT
		rm tmp-cpu.csv
		rm tmp-dev.csv
		#
                # Con el CSV de los discos generamos otros tres con el %busy, blocks/s y avservt
                #
                for ana in $ANALISYS
                do
                        INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
                        echo "$INST_TIME - Generando $ana para $MAQ ..." >> $LOGFILE
                        ANA_OUTFILE=diskuse_$ana-$MAQ-$MESANIO.csv
                        LC_ALL=es_ES; /usr/bin/nawk -f $BASEDIR/bin/$ana-devs.awk ${CSVDEVOUT}  > $ANA_OUTFILE; LC_ALL=C
                done
		#
		# Guardamos el estado de ocupacion de los filesystem
		#
		$SSH_CMD ieci@$MAQ "$DFCMD" | awk -f $BASEDIR/bin/dfparser.awk > $FSOUTFILE 2> $ERRORLOG
                INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
                echo "$INST_TIME - Graficas mensuales para $MAQ generadas" >> $LOGFILE
                ;;
	*)
		echo "Periodo no valido, valores posibles: hist o mensual"
		exit 1
		;;
esac

INST_TIME=`/usr/bin/date +'%b %d %H:%M:%S'`
echo "$INST_TIME - Proceso de extraccion de datos para $MAQ finalizado." >> $LOGFILE
