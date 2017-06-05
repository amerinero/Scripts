# Desde linea de comandos nos tiene que llegar el nombre del fichero csv de partida para incluir el enlace.

BEGIN {
	FS=";";
	print "<P><CENTER><H2><B>"CSVFILE"</B></H2></CENTER>";
	print "<TABLE style=\"font-size:small;\" BORDER=1 WIDTH=100%>";
} 

{
	print "<TR>";
	for (i=1; i<=NF; ++i)
	{
		if (NR==1) 
			print "   <TD><B><TT>"$i"</TT></B></TD>"; 
		else
			print "   <TD><TT>"$i"</TT></TD>";
	}
	print "</TR>";
} 

END {
	print "</TABLE>";
	print "<A HREF=\""CSVFILE"\">Descarga fichero CSV</A>";
} 
