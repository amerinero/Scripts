#!/usr/bin/bash
FECHA=`date +%H%M%S-%d%m%Y`
HOST=`hostname`
FILEOUT=SunClusterGetInfo_${HOST}_${FECHA}.txt

echo "*******************************************************************" >> $FILEOUT
echo "*** Estado General ***" >> $FILEOUT
echo "*******************************************************************" >> $FILEOUT
echo "--- scstat" >> $FILEOUT
scstat >> $FILEOUT
echo "-------------------------------------------------------------------" >> $FILEOUT

echo "*******************************************************************" >> $FILEOUT
echo "*** Grupos de Recursos y Recursos definidos ***" >> $FILEOUT
echo "*******************************************************************" >> $FILEOUT
RGS=`clresourcegroup list`
for RG in $RGS
do
  echo "--- clresourcegroup show -v $RG" >> $FILEOUT
  clresourcegroup show -v $RG >> $FILEOUT
  echo "-------------------------------------------------------------------" >> $FILEOUT
done

echo "*******************************************************************" >> $FILEOUT
echo "*** Quorum ***" >> $FILEOUT
echo "*******************************************************************" >> $FILEOUT
QDEVS=`clquorum list`
for QD in $QDEVS
do
  echo "--- clquorum show $QD" >> $FILEOUT
  clquorum show $QD >> $FILEOUT
  echo "-------------------------------------------------------------------" >> $FILEOUT
done

echo "*******************************************************************" >> $FILEOUT
echo "*** Cluster Interconnect ***" >> $FILEOUT
echo "*******************************************************************" >> $FILEOUT
echo "--- clinterconnect show" >> $FILEOUT
clinterconnect show >> $FILEOUT
echo "-------------------------------------------------------------------" >> $FILEOUT
