#!/bin/bash

hosts="
192.168.2.21  node1.tp2.b2
192.168.2.22  node2.tp2.b2
"

echo -e "${hosts}" > /etc/hosts
ip route add 192.168.2.0/24 via 192.168.2.22 dev eth1