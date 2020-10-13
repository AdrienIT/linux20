#!/bin/bash
# AdrienIT

yum install nfs-utils

systemctl start nfs-server rpcbind
systemctl enable nfs-server rpcbind

mkdir /nfsfileshare

chmod 777 /nfsfileshare/

echo -e "
/nfsfileshare   192.168.4.11(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)
/nfsfileshare   192.168.4.12(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)
/nfsfileshare   192.168.4.13(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)
" > /etc/exports

exportfs -r

firewall-cmd --permanent --add-service mountd
firewall-cmd --permanent --add-service rpc-bind
firewall-cmd --permanent --add-service nfs
firewall-cmd --reload

