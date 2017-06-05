set terminal jpeg size 1280,800
set multiplot
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set datafile separator "|"
set yrange  [0:*]
set grid xtics
set grid ytics
#
# blks/s + r+w/s
#
set ylabel "kbytes"
set xlabel "Fecha"
set size 0.4,0.5
set origin 0.1,0.0
set tmargin 0
set bmargin 3
set rmargin 0
set lmargin 1
plot "< sqlite3 mayo.db \"select Fecha,Value/2 from SYSDATA where Device='sd0' and Parameter='blks/s'\"" using 1:2 title "blks/s" smooth csplines,\
     "< sqlite3 mayo.db \"select Fecha,Value/2 from SYSDATA where Device='sd0' and Parameter='r+w/s'\"" using 1:2 title "r+w/s" smooth csplines
#
# avque
#
set xdata time
set ylabel "Avg. # requests"
set size 0.4,0.5
set origin 0.6,0.0
set bmargin 3
set tmargin 0
set rmargin 1
set lmargin 0
plot "< sqlite3 mayo.db \"select Fecha,Value from SYSDATA where Device='sd0' and Parameter='avque'\"" using 1:2 title "avque" smooth csplines
#
# %busy
#
set ylabel "%busy"
set size 0.4,0.5
set origin 0.1,0.5
set bmargin 0
set tmargin 1
set rmargin 0
set lmargin 1
set format x ""
set xlabel ""
plot "< sqlite3 mayo.db \"select Fecha,Value from SYSDATA where Device='sd0' and Parameter='%busy'\"" using 1:2 title "%busy" smooth csplines
#
# avwait + avserv
#
set ylabel "ms"
set size 0.4,0.5
set origin 0.6,0.5
set bmargin 0
set tmargin 1
set rmargin 1
set lmargin 0
set format x ""
set xlabel ""
plot "< sqlite3 mayo.db \"select Fecha,Value from SYSDATA where Device='sd0' and Parameter='avwait'\"" using 1:2 title "avwait" smooth csplines,\
     "< sqlite3 mayo.db \"select Fecha,Value from SYSDATA where Device='sd0' and Parameter='avserv'\"" using 1:2 title "avserv" smooth csplines
set nomultiplot
