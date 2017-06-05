set terminal x11
set xdata time
set timefmt "%Y-%m-%d-%H:%M:%S"
set yrange  [0:*]
set grid xtics
set grid ytics
set ylabel "kB/s"
plot "rxkb.dat" using 1:2 title "rx" smooth csplines,\
     "txkb.dat" using 1:2 title "tx" smooth csplines
pause -1
