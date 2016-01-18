#!/bin/sh

t=10

for i in 20000 2000 20000 1000 18000 1500 19000 5000; do
echo "CBR Rate = $i"
mvconfig -s /videoAvc/mainAvcTable/avcBitrate/1 $i
sleep 0.2
done

