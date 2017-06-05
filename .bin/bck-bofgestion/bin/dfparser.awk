# Filtro para generar archivos csv con la salida del df -k. 
# 
# Se usa desde Recollect.sh
#
# Esperamos la salida del comando:
# df -k | egrep -v 'devices|contract|proc|mnttab|volatile|object|sharetab|libc_psr|fd'
#
BEGIN {

        OFMT="%.0f";
        print "Filesystem;Total Size;Used Size"

}

{
        if ( $1 != "Filesystem" )
                print $6";"$2/1024";"$3/1024;
}

END {

}
