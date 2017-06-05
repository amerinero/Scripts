set terminal x11 font "Arial,10"
set multiplot
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set datafile separator "|"
set yrange  [0:100]
set grid xtics
set grid ytics
set ylabel "%Memused"
set xlabel "Fecha"
set size 1,0.4
set origin 0.0,0.0
set tmargin 0
set bmargin 3
plot "< sqlite3 mayo.db \"select Fecha,Value from SYSDATA where Device='MEM' and Parameter='%memused'\"" using 1:2 title "%memused" smooth csplines
set ylabel "%CPU"
set size 1,0.6
set origin 0.0,0.4
set bmargin 0
set tmargin 1
set format x ""
set xlabel ""
plot "< sqlite3 mayo.db \"select Fecha,Value from SYSDATA where Device='CPU-all' and Parameter='%usr'\"" using 1:2 title "%usr" smooth csplines,\
     "< sqlite3 mayo.db \"select Fecha,Value from SYSDATA where Device='CPU-all' and Parameter='%sys'\"" using 1:2 title "%sys" smooth csplines,\
     "< sqlite3 mayo.db \"select Fecha,Value from SYSDATA where Device='CPU-all' and Parameter='%nice'\"" using 1:2 title "%nice" smooth csplines,\
     "< sqlite3 mayo.db \"select Fecha,Value from SYSDATA where Device='CPU-all' and Parameter='%iowait'\"" using 1:2 title "%iowait" smooth csplines,\
     "< sqlite3 mayo.db \"select Fecha,Value from SYSDATA where Device='CPU-all' and Parameter='%irq'\"" using 1:2 title "%irq" smooth csplines,\
     "< sqlite3 mayo.db \"select Fecha,Value from SYSDATA where Device='CPU-all' and Parameter='%soft'\"" using 1:2 title "%soft" smooth csplines,\
     "< sqlite3 mayo.db \"select Fecha,Value from SYSDATA where Device='CPU-all' and Parameter='%steal'\"" using 1:2 title "%steal" smooth csplines,\
     "< sqlite3 mayo.db \"select Fecha,Value from SYSDATA where Device='CPU-all' and Parameter='%idle'\"" using 1:2 title "%idle" smooth csplines
set nomultiplot
pause -1
