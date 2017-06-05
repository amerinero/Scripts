set terminal x11 font "Arial,10"
set multiplot
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set datafile separator "|"
set yrange  [0:*]
set grid xtics
set grid ytics
set xtics font "Arial,8"
#
# rd + wr 
#
set ylabel "kbytes"
set xlabel "Fecha"
set size 0.4,0.5
set origin 0.1,0.0
set tmargin 0
set bmargin 3
set rmargin 0
set lmargin 1
plot "< sqlite3 mayo.db \"select Fecha,Value/2 from SYSDATA where Device='DEV-dev8-0' and Parameter='rd_sec/s'\"" using 1:2 title "rd_sec/s" smooth csplines,\
     "< sqlite3 mayo.db \"select Fecha,Value/2 from SYSDATA where Device='DEV-dev8-0' and Parameter='wr_sec/s'\"" using 1:2 title "wr_sec/s" smooth csplines
#
# avgrq-sz
#
set xdata time
set ylabel "kbytes"
set size 0.4,0.5
set origin 0.6,0.0
set bmargin 3
set tmargin 0
set rmargin 1
set lmargin 0
plot "< sqlite3 mayo.db \"select Fecha,Value/2 from SYSDATA where Device='DEV-dev8-0' and Parameter='avgrq-sz'\"" using 1:2 title "avgrq-sz" smooth csplines
#
# %Util
#
set ylabel "%util"
set size 0.4,0.5
set origin 0.1,0.5
set bmargin 0
set tmargin 1
set rmargin 0
set lmargin 1
set format x ""
set xlabel ""
plot "< sqlite3 mayo.db \"select Fecha,Value from SYSDATA where Device='DEV-dev8-0' and Parameter='%util'\"" using 1:2 title "%util" smooth csplines
#
# await + svctm
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
plot "< sqlite3 mayo.db \"select Fecha,Value from SYSDATA where Device='DEV-dev8-0' and Parameter='await'\"" using 1:2 title "await" smooth csplines,\
     "< sqlite3 mayo.db \"select Fecha,Value from SYSDATA where Device='DEV-dev8-0' and Parameter='svctm'\"" using 1:2 title "svctm" smooth csplines
set nomultiplot
pause -1
