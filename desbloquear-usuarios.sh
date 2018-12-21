while read usu ; do
    passwd -u $usu 
    passwd -x 182 $usu
	echo temporal | passwd $usu --stdin
	passwd -e $usu
done < "${1:-/dev/stdin}"
