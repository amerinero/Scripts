#
# Filtro para calcular la media de CPU y memoria a partir de la salida del sar -ru de linux 
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
	if (NR==1) { next; }
	if ( $2 > 100 ||  $2 < 0 ||  $3 < 0 ||  $3 > 100) next;
	else {
		avgCPU=avgCPU+$2;
		avgMEM=avgMEM+$3;
		cnt++;
	}	
} 

END {
	printf ("%2.2f;%2.2f\n",avgCPU/cnt,avgMEM/cnt); 
} 
