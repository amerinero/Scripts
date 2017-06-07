#!/usr/bin/bash
FECHA=`date +%H%M%S-%d%m%Y`
HOST=`hostname`
FILEOUT=SolarisGetInfo_${HOST}_${FECHA}.txt

echo "*******************************************************************" >> $FILEOUT
echo "*** DISCOS ***" >> $FILEOUT
echo "*******************************************************************" >> $FILEOUT
echo "--- format" >> $FILEOUT
format << EOL >> $FILEOUT
EOL
echo "-------------------------------------------------------------------" >> $FILEOUT
echo "--- zpool list" >> $FILEOUT
zpool list >> $FILEOUT
echo "-------------------------------------------------------------------" >> $FILEOUT
echo "--- zpool status" >> $FILEOUT
zpool status >> $FILEOUT
echo "-------------------------------------------------------------------" >> $FILEOUT
echo "--- zfs list" >> $FILEOUT
zfs list >> $FILEOUT
echo "-------------------------------------------------------------------" >> $FILEOUT

echo "*******************************************************************" >> $FILEOUT
echo "*** FILESYSYTEMS ***" >> $FILEOUT
echo "*******************************************************************" >> $FILEOUT
echo "--- cat /etc/vfstab" >> $FILEOUT
cat /etc/vfstab >> $FILEOUT
echo "-------------------------------------------------------------------" >> $FILEOUT
echo "--- df -h" >> $FILEOUT
df -h >> $FILEOUT
echo "-------------------------------------------------------------------" >> $FILEOUT

echo "*******************************************************************" >> $FILEOUT
echo "*** RED ***" >> $FILEOUT
echo "*******************************************************************" >> $FILEOUT
echo "--- ifconfig -a" >> $FILEOUT
ifconfig -a >> $FILEOUT
echo "-------------------------------------------------------------------" >> $FILEOUT
echo "--- netstat -rnv" >> $FILEOUT
netstat -rnv >> $FILEOUT
echo "-------------------------------------------------------------------" >> $FILEOUT
echo "--- ls -l /etc/hostname.* ; cat /etc/hostname.*" >> $FILEOUT
ls -l /etc/hostname.* >> $FILEOUT ; cat /etc/hostname.* >> $FILEOUT
echo "-------------------------------------------------------------------" >> $FILEOUT
echo "--- cat /etc/netmasks" >> $FILEOUT
cat /etc/netmasks >> $FILEOUT
echo "-------------------------------------------------------------------" >> $FILEOUT
echo "--- cat /etc/hosts" >> $FILEOUT
cat /etc/hosts >> $FILEOUT
echo "-------------------------------------------------------------------" >> $FILEOUT
echo "--- netstat -an | grep LISTEN (puertos escuchando)" >> $FILEOUT
netstat -an | grep LISTEN >> $FILEOUT
echo "-------------------------------------------------------------------" >> $FILEOUT

echo "*******************************************************************" >> $FILEOUT
echo "*** SERVICIOS ***" >> $FILEOUT
echo "*******************************************************************" >> $FILEOUT
echo "--- svcs -a" >> $FILEOUT
svcs -a >> $FILEOUT
echo "-------------------------------------------------------------------" >> $FILEOUT
echo "--- ls -l /etc/rc[23].d/" >> $FILEOUT
ls -l /etc/rc[23].d/ >> $FILEOUT
echo "-------------------------------------------------------------------" >> $FILEOUT

echo "*******************************************************************" >> $FILEOUT
echo "*** PROCESOS ***" >> $FILEOUT
echo "*******************************************************************" >> $FILEOUT
echo "--- ps -ef" >> $FILEOUT
ps -ef >> $FILEOUT
echo "-------------------------------------------------------------------" >> $FILEOUT

echo "*******************************************************************" >> $FILEOUT
echo "*** ZONAS ***" >> $FILEOUT
echo "*******************************************************************" >> $FILEOUT
echo "--- zoneadm list -iv" >> $FILEOUT
zoneadm list -iv >> $FILEOUT
echo "-------------------------------------------------------------------" >> $FILEOUT
echo "--- ls -l /etc/zones" >> $FILEOUT
ls -l /etc/zones >> $FILEOUT
echo "-------------------------------------------------------------------" >> $FILEOUT

echo "*******************************************************************" >> $FILEOUT
echo "*** LDOMS ***" >> $FILEOUT
echo "*******************************************************************" >> $FILEOUT
echo "--- ldm ls" >> $FILEOUT
ldm ls >> $FILEOUT
echo "-------------------------------------------------------------------" >> $FILEOUT
for LDOM in `ldm ls | grep -v NAME | awk '{print $1}'`
do
  echo "--- ldm ls -l $LDOM" >> $FILEOUT
  ldm ls -l $LDOM >> $FILEOUT
  echo "-------------------------------------------------------------------" >> $FILEOUT
done
