#

BEGIN {
	FS=";";
} 

{
	if (NR==1) { next; }
	else {
		pocupado=($3/$2)*100;
		if (pocupado>75) {printf ("%s;%s;%2.2f\n",SERV,$1,pocupado); }
	}

} 

END {
} 
