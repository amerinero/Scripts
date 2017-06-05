#
# Filtro awk para generar lineas SQL tipo insert into .... 
# a partir del sar -A de una máquina linux.
# 
#
# Solo se recogen los datos de:
# - sar -d   
# - sar -P ALL
# - sar -n DEV
# - sar -r
# - sar -b
# - sar -q
# - sar -S
# - sar -W
# - sar -B
# - sar -w
#
# El resto de datos de un sar -A se descarta. 
# 
# Los inserts van contra una tabla llamada SYSDATA con el siguiente formato:
# CREATE TABLE SYSDATA (Fecha DATE,
#                       Sysname VARCHA(30), 
#                       Device VARCHAR(20), 
#                       Parameter VARCHAR(20), 
#                       Value REAL);
#
# Ejemplo de uso con sqlite:
# PROMPT> sqlite3 test.db "CREATE TABLE SYSDATA (Fecha DATE,Sysname VARCHA(30),Device VARCHAR(20),Parameter VARCHAR(20),Value REAL);"
# PROMPT> export LC_ALL=C; sar -A | awk -f sarLinux2DB.awk |  sqlite3 test.db
# PROMPT> sqlite3 test.db "select * from SYSDATA;"
# 
# Amerinero
#
BEGIN { 
  MARK=0; 
  print "BEGIN TRANSACTION;";
  TABLE="SYSDATA"; 
}
{
	if ( NR == 1 ) 
	{
		SYSNAME=$3;
		gsub(/\(|\)/,"",SYSNAME);
		split($4,FECHA,/\//);
		next;
	}
	
	if ( MARK == 5  ) # Actualizamos el array de categorias
	{
		for (cnt=2; cnt <= NF; cnt++) COLS[cnt]=$cnt;
		MARK=1;
		next;
	}
		
 	if ($0 == "") 
	{
		MARK=5; # La siguiente linea sera de cabeceras
		next;
	}
	if ($1 == "Average:") next;
	
	if (COLS[2] ~ /CPU|DEV|IFACE/)
		# 
		# Para la salida de:
		# - sar -pd
		#	- sar -P ALL
		#	- sar -n DEV
		#
	{
		for (cnt=3; cnt <= NF; cnt++) 
			printf "insert into %s values('20%s-%s-%s %s','%s','%s-%s','%s',%s);\n"\
			,TABLE,FECHA[3],FECHA[1],FECHA[2],$1,SYSNAME,COLS[2],$2,COLS[cnt],$cnt;
	}
	
	if (COLS[2] ~ /kbmemfree/)
	{
	 
		for (cnt=2; cnt <= NF; cnt++)
                	printf "insert into %s values('20%s-%s-%s %s','%s','MEM','%s',%s);\n"\
			,TABLE,FECHA[3],FECHA[1],FECHA[2],$1,SYSNAME,COLS[cnt],$cnt;
	}

	if (COLS[2] ~ /tps/) # para sar -b
        {

                for (cnt=2; cnt <= NF; cnt++)
                        printf "insert into %s values('20%s-%s-%s %s','%s','IO','%s',%s);\n"\
                        ,TABLE,FECHA[3],FECHA[1],FECHA[2],$1,SYSNAME,COLS[cnt],$cnt;
        }

	if (COLS[2] ~ /runq-sz/) # para sar -q
        {

                for (cnt=2; cnt <= NF; cnt++)
                        printf "insert into %s values('20%s-%s-%s %s','%s','LOAD','%s',%s);\n"\
                        ,TABLE,FECHA[3],FECHA[1],FECHA[2],$1,SYSNAME,COLS[cnt],$cnt;
        }

	if (COLS[2] ~ /kbswpfree|pswpin/ ) # para sar -S y sar -W
        {

                for (cnt=2; cnt <= NF; cnt++)
                        printf "insert into %s values('20%s-%s-%s %s','%s','SWAP','%s',%s);\n"\
                        ,TABLE,FECHA[3],FECHA[1],FECHA[2],$1,SYSNAME,COLS[cnt],$cnt;
        }

	if (COLS[2] ~ /pgpgin/) # para sar -B
        {

                for (cnt=2; cnt <= NF; cnt++)
                        printf "insert into %s values('20%s-%s-%s %s','%s','PAGING','%s',%s);\n"\
                        ,TABLE,FECHA[3],FECHA[1],FECHA[2],$1,SYSNAME,COLS[cnt],$cnt;
        }

	if (COLS[2] ~ /proc/) # para sar -w
        {

                for (cnt=2; cnt <= NF; cnt++)
                        printf "insert into %s values('20%s-%s-%s %s','%s','PROCS','%s',%s);\n"\
                        ,TABLE,FECHA[3],FECHA[1],FECHA[2],$1,SYSNAME,COLS[cnt],$cnt;
        }
}
END { print "COMMIT;" }
