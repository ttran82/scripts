#!/bin/sh

t=1

for i in 61 60 59 58 57 56 55 54 53 52 51 12 11 10 9 8 7 6 5 4 3 2 1 ; do
  cp ifcfg-eth0-temp ifcfg-eth0
  cp ifcfg-eth1-temp ifcfg-eth1
  cp ifcfg-eth3-temp ifcfg-eth3

  echo "IPADDR=10.27.1.$t" >> ifcfg-eth0
  echo "NETMASK=255.255.255.0" >> ifcfg-eth0


  echo "IPADDR=10.26.1.$t" >> ifcfg-eth1
  echo "NETMASK=255.255.255.0" >> ifcfg-eth1

  echo "DHCP_HOSTNAME=sm-me$t" >> ifcfg-eth3

  scp ifcfg-eth* sm-me$t:/etc/sysconfig/network-scripts
  ssh sm-me$t hostname sm-me$t
  ssh sm-me$t reboot
  t=$(($t+1))
done

