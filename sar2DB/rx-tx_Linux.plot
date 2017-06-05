set terminal wxt 
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set yrange  [0:*]
set grid xtics
set grid ytics
set ylabel "kB/s"
set datafile separator "|"
plot "< sqlite3 mayo.db \"select Fecha,Value from SYSDATA where Device='IFACE-eth0' and Parameter='txkB/s'\"" using 1:2 title "tX" smooth csplines,\
     "< sqlite3 mayo.db \"select Fecha,Value from SYSDATA where Device='IFACE-eth0' and Parameter='rxkB/s'\"" using 1:2 title "rX" smooth csplines
pause -1
