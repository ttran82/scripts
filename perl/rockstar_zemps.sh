#!/bin/sh

t=1

ofile=rockstar_zemps.txt
rm $ofile
touch $ofile 

for i in rqa1-eth0 rqa2-eth0 rqa3-eth0 rqa4-eth0 rqa5-eth0 rqa6-eth0 rqa7-eth0 rqa8a-eth0 rqa9a-eth0 rqa10a-eth1 rqa11a-eth0 rqa12a-eth1 rqa13a-eth1 rqa14a-eth1 rqa15a-eth1 rqa17a-eth1 rqa18a-eth1 se-6k-1 se-6k-2 se-6k-3 se-6k-4 se-6k-5 se-6k-6 se-6k-7 se-6k-8 se-6k-9; do

  echo "$i":  >> $ofile
  ./mvprexec.exp $i 'cat /proc/zemps | grep -i version'
  echo "$temp"

done

