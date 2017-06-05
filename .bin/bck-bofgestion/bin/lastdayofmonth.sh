#!/usr/bin/bash
lastday=`/usr/bin/echo $(/usr/bin/cal) | awk '{print $NF}'`
hoy=`/usr/bin/date +%d`
if [ $hoy -eq $lastday ]
then
	exit 0
else 
	exit 1
fi
