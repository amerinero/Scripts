set terminal x11
set multiplot 
set xdata time
set timefmt "%H:%M:%S"
set yrange  [0:100]
set grid xtics
set grid ytics
set ylabel "% memused"
set size 1,0.4
set origin 0.0,0.0
plot "sar-r.dat" using 1:4 title "%memused" smooth csplines
set ylabel "CPU use"
set size 1,0.6
set origin 0.0,0.4
plot \
  "sar-u.dat" using 1:3 title "%user" smooth csplines,\
  "sar-u.dat" using 1:4 title "%nice" smooth csplines,\
  "sar-u.dat" using 1:5 title "%system" smooth csplines,\
  "sar-u.dat" using 1:6 title "%iowait" smooth csplines,\
  "sar-u.dat" using 1:7 title "%steal" smooth csplines,\
  "sar-u.dat" using 1:8 title "%idle" smooth csplines
set nomultiplot
pause -1
