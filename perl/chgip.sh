#!/bin/sh

cd /etc/sysconfig/network-scripts

sed -i 's/GATEWAY=10.0.20.1/GATEWAY=10.77.162.254/' ifcfg-eth0
sed -i 's/GATEWAY=10.0.20.1/GATEWAY=10.77.162.254/' ifcfg-eth1
sed -i 's/GATEWAY=10.0.20.1/GATEWAY=10.77.162.254/' ifcfg-eth2
sed -i 's/GATEWAY=10.0.20.1/GATEWAY=10.77.162.254/' ifcfg-eth3
sed -i 's/GATEWAY=10.0.21.1/GATEWAY=10.77.163.254/' ifcfg-eth0
sed -i 's/GATEWAY=10.0.21.1/GATEWAY=10.77.163.254/' ifcfg-eth1
sed -i 's/GATEWAY=10.0.21.1/GATEWAY=10.77.163.254/' ifcfg-eth2
sed -i 's/GATEWAY=10.0.21.1/GATEWAY=10.77.163.254/' ifcfg-eth3
sed -i 's/GATEWAY=10.0.22.1/GATEWAY=10.77.164.254/' ifcfg-eth0
sed -i 's/GATEWAY=10.0.22.1/GATEWAY=10.77.164.254/' ifcfg-eth1
sed -i 's/GATEWAY=10.0.22.1/GATEWAY=10.77.164.254/' ifcfg-eth2
sed -i 's/GATEWAY=10.0.22.1/GATEWAY=10.77.164.254/' ifcfg-eth3
sed -i 's/GATEWAY=10.0.23.1/GATEWAY=10.77.165.254/' ifcfg-eth0
sed -i 's/GATEWAY=10.0.23.1/GATEWAY=10.77.165.254/' ifcfg-eth1
sed -i 's/GATEWAY=10.0.23.1/GATEWAY=10.77.165.254/' ifcfg-eth2
sed -i 's/GATEWAY=10.0.23.1/GATEWAY=10.77.165.254/' ifcfg-eth3

sed -i 's/10.0.20/10.77.162/' ifcfg-eth0
sed -i 's/10.0.20/10.77.162/' ifcfg-eth1
sed -i 's/10.0.20/10.77.162/' ifcfg-eth2
sed -i 's/10.0.20/10.77.162/' ifcfg-eth3
sed -i 's/10.0.21/10.77.163/' ifcfg-eth0
sed -i 's/10.0.21/10.77.163/' ifcfg-eth1
sed -i 's/10.0.21/10.77.163/' ifcfg-eth2
sed -i 's/10.0.21/10.77.163/' ifcfg-eth3
sed -i 's/10.0.22/10.77.164/' ifcfg-eth0
sed -i 's/10.0.22/10.77.164/' ifcfg-eth1
sed -i 's/10.0.22/10.77.164/' ifcfg-eth2
sed -i 's/10.0.22/10.77.164/' ifcfg-eth3
sed -i 's/10.0.23/10.77.165/' ifcfg-eth0
sed -i 's/10.0.23/10.77.165/' ifcfg-eth1
sed -i 's/10.0.23/10.77.165/' ifcfg-eth2
sed -i 's/10.0.23/10.77.165/' ifcfg-eth3

service network restart

