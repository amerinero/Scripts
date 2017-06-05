#!/usr/bin/bash
#
# Para empaquetar
#
# Configuracion
#
BASEDIR=/local3/rendimiento/gcapacidad
LOGFILE=$BASEDIR/log/packager.log

if [ $1 ]
then
        case "$1" in
                hist)
			DATADIR=$BASEDIR/data/historico
                        ;;
                mensual)
			DATADIR=$BASEDIR/data/mensual
                        ;;
                informes)
			DATADIR=$BASEDIR/informes
                        ;;
                zonas)
			DATADIR=$BASEDIR/data/zonas
                        ;;
                *)
                        echo "Periodo no valido, valores posibles: hist o mensual"
                        exit 1
                        ;;
        esac
else
        echo "Falta Periodo..."
        echo "$0 periodo(hist/mensual/informes/zonas)"
        exit 1
fi

cd $DATADIR

if [ -f $1.tar ]
then
	rm $1.tar
fi
if [ -f $1.tar.gz ]
then
	rm $1.tar.gz
fi

/usr/bin/tar cvf $1.tar * > $LOGFILE
/usr/bin/gzip $1.tar 
