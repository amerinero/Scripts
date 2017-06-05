#
# Filtro para generar un archivo .csv con el avserv de cada disco fisico (sd o ssd) presente en el archivo
# .../data/mensual/<maq>/dev-<maq>-<MESANIO>.csv. En dev-<maq>-<MESANIO>.csv hay muchos datos juntos
# y es mejor ir separandolos
#
# Ejemplo de uso: nawk -f avserv-devs.awk ../data/mensual/bof-gestion1/dev-bof-gestion1-042010.csv

BEGIN {
	FS=";";
	cnt=0;
	i=1;
} 

{
	if (NR==1) {
		for ( cnt=1; cnt <= NF; cnt++ ) 
			{ if ($cnt ~ /sd.*avserv/) {COLS[$i]=cnt; i++};
			  if ($cnt ~ /vdc.*avserv/) {COLS[$i]=cnt; i++};
		 	}
		NCOLS=i-1;
		# Sacamos la cabezera
		printf ("%s;", "Date");
		for (c in COLS)
                        { printf ("%s;",$COLS[c]) };
	}
	else {
        	if ($2=="") next;
		printf ("%s;", $1);
		for (c in COLS)
                        { printf ("%2.2f;",$COLS[c]) }
	}
	print "";

} 

END {
} 
