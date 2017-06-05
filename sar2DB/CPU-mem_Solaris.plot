set terminal x11 font "Arial,10"
set multiplot
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set datafile separator "|"
set yrange  [0:*]
set grid xtics
set grid ytics
set ylabel "Mem. pages"
set xlabel "Fecha"
set size 1,0.4
set origin 0.0,0.0
set tmargin 0
set bmargin 3
set lmargin 12 
plot "< sqlite3 mayo.db \"select Fecha,Value from SYSDATA where Device='MEM' and Parameter='freemem'\"" using 1:2 title "freemem" smooth csplines
set ylabel "%CPU"
set yrange  [0:100]
set size 1,0.6
set origin 0.0,0.4
set bmargin 0
set tmargin 1
set lmargin 12
set format x ""
set xlabel ""
plot "< sqlite3 mayo.db \"select Fecha,Value from SYSDATA where Device='CPU' and Parameter='%usr'\"" using 1:2 title "%usr" smooth csplines,\
     "< sqlite3 mayo.db \"select Fecha,Value from SYSDATA where Device='CPU' and Parameter='%sys'\"" using 1:2 title "%sys" smooth csplines,\
     "< sqlite3 mayo.db \"select Fecha,Value from SYSDATA where Device='CPU' and Parameter='%wio'\"" using 1:2 title "%wio" smooth csplines,\
     "< sqlite3 mayo.db \"select Fecha,Value from SYSDATA where Device='CPU' and Parameter='%idle'\"" using 1:2 title "%idle" smooth csplines
set nomultiplot
pause -1
