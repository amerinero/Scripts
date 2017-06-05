#
# Filtro awk para generar lineas SQL tipo insert into .... 
# a partir del sar -A de una máquina solaris.
# 
#
# Solo se recogen los datos de:
# - sar -d   
# - sar -c
# - sar -u
# - sar -r
# - sar -q
# - sar -a
# - sar -b
# - sar -w
# - sar -p
# - sar -g
# - sar -v
# - sar -m
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
# PROMPT> export LC_ALL=C; sar -A | awk -f sarSolaris2DB.awk |  sqlite3 test.db
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
 	if ($0 == "") 
	{
#		printf "LineaB=%d\n",NR;
		if (MARK==3) MARK=3; else MARK=5; # La siguiente linea sera de cabeceras
		next;
	}

	if ($1 == "Average") 
	{
		if (MARK == 3) MARK=5;
		next;
	}

	if ( NR == 2 ) 
	{
		SYSNAME=$2;
		gsub(/\(|\)/,"",SYSNAME);
		split($6,FECHA,/\//);
		MARK=1;
		next;
	}

	if ( MARK == 5  ) # Actualizamos el array de categorias
	{
		for (cnt=2; cnt <= NF; cnt++) COLS[cnt]=$cnt;
#		printf "LineaM=%d\n",NR;
#		printf "MARK=%d,COLS[2]=%s\n",MARK,COLS[2];
		if (COLS[2] == "device") MARK=3; else MARK=1;	
		next;
	}
		
#	printf "MARK=%d,COLS[2]=%s\n",MARK,COLS[2];
	
	if (COLS[2] ~ /device/) # sar -d
	{
		if (NF == 8)
		{
			TIMEDEV=$1;
			for (cnt=3; cnt <= NF; cnt++)
        printf "insert into %s values('%s-%s-%s %s','%s','%s','%s',%s);\n"\
        ,TABLE,FECHA[3],FECHA[1],FECHA[2],$1,SYSNAME,$2,COLS[cnt],$cnt;
		}
		else
		{
			for (cnt=2; cnt <= NF; cnt++)
				printf "insert into %s values('%s-%s-%s %s','%s','%s','%s',%s);\n"\
				,TABLE,FECHA[3],FECHA[1],FECHA[2],TIMEDEV,SYSNAME,$1,COLS[cnt+1],$cnt;

		}
	}

	if (COLS[2] ~ /scall/) # sar -c
        {

                for (cnt=2; cnt <= NF; cnt++)
                        printf "insert into %s values('%s-%s-%s %s','%s','SYSCALLS','%s',%s);\n"\
                        ,TABLE,FECHA[3],FECHA[1],FECHA[2],$1,SYSNAME,COLS[cnt],$cnt;
        }
	
	if (COLS[2] ~ /%usr/) # sar -u
        {

                for (cnt=2; cnt <= NF; cnt++)
                        printf "insert into %s values('%s-%s-%s %s','%s','CPU','%s',%s);\n"\
                        ,TABLE,FECHA[3],FECHA[1],FECHA[2],$1,SYSNAME,COLS[cnt],$cnt;
        }

	if (COLS[2] ~ /freemem/) # sar -r
	{
	 
		for (cnt=2; cnt <= NF; cnt++)
                	printf "insert into %s values('%s-%s-%s %s','%s','MEM','%s',%s);\n"\
			,TABLE,FECHA[3],FECHA[1],FECHA[2],$1,SYSNAME,COLS[cnt],$cnt;
	}

	if (COLS[2] ~ /bread|iget/) # para sar -ab
        {

                for (cnt=2; cnt <= NF; cnt++)
                        printf "insert into %s values('%s-%s-%s %s','%s','IO','%s',%s);\n"\
                        ,TABLE,FECHA[3],FECHA[1],FECHA[2],$1,SYSNAME,COLS[cnt],$cnt;
        }

	if (COLS[2] ~ /runq-sz/) # para sar -q
        {

                for (cnt=2; cnt <= NF; cnt++)
                        printf "insert into %s values('%s-%s-%s %s','%s','LOAD','%s',%s);\n"\
                        ,TABLE,FECHA[3],FECHA[1],FECHA[2],$1,SYSNAME,COLS[cnt],$cnt;
        }

	if (COLS[2] ~ /swpin/ ) # sar -w
        {

                for (cnt=2; cnt <= NF; cnt++)
                        printf "insert into %s values('20%s-%s-%s %s','%s','SWAP','%s',%s);\n"\
                        ,TABLE,FECHA[3],FECHA[1],FECHA[2],$1,SYSNAME,COLS[cnt],$cnt;
        }

	if (COLS[2] ~ /pgout|atch/) # para sar -pg
        {

                for (cnt=2; cnt <= NF; cnt++)
                        printf "insert into %s values('20%s-%s-%s %s','%s','PAGING','%s',%s);\n"\
                        ,TABLE,FECHA[3],FECHA[1],FECHA[2],$1,SYSNAME,COLS[cnt],$cnt;
        }

	if (COLS[2] ~ /proc-sz/) # para sar -v
        {

                for (cnt=2; cnt <= NF; cnt++)
                        printf "insert into %s values('20%s-%s-%s %s','%s','PROCS','%s',%s);\n"\
                        ,TABLE,FECHA[3],FECHA[1],FECHA[2],$1,SYSNAME,COLS[cnt],$cnt;
        }

	if (COLS[2] ~ /msg/) # para sar -m
        {

                for (cnt=2; cnt <= NF; cnt++)
                        printf "insert into %s values('20%s-%s-%s %s','%s','SEMA','%s',%s);\n"\
                        ,TABLE,FECHA[3],FECHA[1],FECHA[2],$1,SYSNAME,COLS[cnt],$cnt;
        }
}
END { print "COMMIT;" }
