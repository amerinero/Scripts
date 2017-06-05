#
# Filtro para calcular la media de CPU y memoria a partir de la salida del sar -ru de solaris
#
# Se usa desde mediaCPUMEM.sh
#
BEGIN {
	FS=";";
	OFS=";";
} 

{
	if (NR==1) {printf ("%s%s;\n",$0,"% Free Mem."); next;} 
	if ($2=="") {next;}
	freembytes=($6*PAGE)/1024/1024;
	percentfree=(freembytes/MEMS)*100;
	printf ("%s%2.2f;\n",$0,percentfree);
} 

END {
} 
