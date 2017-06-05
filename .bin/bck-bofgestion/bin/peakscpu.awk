#

BEGIN {
	FS=";";
} 

{
	if (NR==1) { next; }
	else {
		if (NF==9) # Solaris
		{
			if ($2<10) { printf ("%s;%s;%2.2f\n",SERV,$1,100-$2) }
		}
		else # Linux
		{
#			print "VALOR=",$7;
			if ($7 != "")  {
                        	if ($7<10) { printf ("%s;%s;%2.2f\n",SERV,$1,100-$7) }
			}
                }
	}

} 

END {
} 
