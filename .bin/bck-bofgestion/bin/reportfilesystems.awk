#

BEGIN {
	FS=";";
} 

{
	if (NR==1) { next; }
	else {
		pocupado=($3/$2)*100;
		printf ("%s;%s;%d;%2.2f\n",SERV,$1,$3,pocupado);
	}

} 

END {
} 
