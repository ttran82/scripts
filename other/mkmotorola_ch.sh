#!/bin/sh

t=1
c=0

cfile=channeltable.txt

rm $cfile
touch $cfile

for i in 20 22 24; do

  for j in 1 2 3 4 5 6 7 8 9 10 11 12; do
  
       echo "$t;QA_233.0.$i.$j;233.0.$i.$j:8433;" >> $cfile
       t=$(($t+1))

  done

done

for i in 25 27; do

  for j in 1 2 3 4 5 6 7 8 9 10 11 12; do

       echo "$t;ENGR_233.0.$i.$j;233.0.$i.$j:8433;" >> $cfile
       t=$(($t+1))

  done

done

for i in 26 28 222; do

  for j in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do

       echo "$t;QA_233.0.$i.$j;233.0.$i.$j:8433;" >> $cfile
       t=$(($t+1))

  done

done



