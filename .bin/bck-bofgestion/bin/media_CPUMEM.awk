#
# Filtro para calcular la media de CPU y memoria a partir de la salida del sar -ru de solaris
#
# Se usa desde mediaCPUMEM.sh
#
BEGIN {
	FS=";";
	avgCPU=0; 
	avgMEM=0;
	cnt=0;
} 

{

	if (NF > 9) # Fichero de datos linux
	{
		if ( $3 > 100 ||  $3 < 0 ||  $7 < 0 ||  $7 > 100) next;
		avgCPU=avgCPU+100-$7;
		avgMEM=avgMEM+$3;
		cnt++;
	}
	else  # Fichero de datos Solaris
	{	
		if ( $8 > 100 ||  $8 < 0 ||  $2 < 0 ||  $2 > 100) next;
		avgCPU=avgCPU+100-$2;
		avgMEM=avgMEM+100-$8;
		cnt++;
	} 
}

END {
	printf ("%2.2f;%2.2f\n",avgCPU/cnt,avgMEM/cnt); 
} 
