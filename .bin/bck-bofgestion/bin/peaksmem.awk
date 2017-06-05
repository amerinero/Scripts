#

BEGIN {
	FS=";";
} 

{
	if (NR==1) { next; }
	else {
		if (NF==9) # Solaris
		{
			if ($8<=10) { printf ("%s;%s;%2.2f\n",SERV,$1,100-$8) }
		}
		else # Linux
		{
                        if ($3>=90) { printf ("%s;%s;%2.2f\n",SERV,$1,$3) }
                }
	}

} 

END {
} 
