#!/bin/sh

t=1

ofile=rockstar_sensors.txt
rm $ofile
touch $ofile 

for i in rqa1-eth0 rqa2-eth0 rqa3-eth0 rqa4-eth0 rqa5-eth0 rqa6-eth0 rqa7-eth0 rqa8-eth0 rqa9-eth0 rqa10-eth1 rqa11-eth0 rqa12-eth1 rqa13-eth1 rqa14-eth1 rqa15-eth1 rqa16-eth1 rqa17-eth1 rqa18-eth1; do

  echo "$i":  >> $ofile
  ./mvprexec.exp $i sensors | grep -i 12vcc >> $ofile

done

