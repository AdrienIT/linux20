#!/bin/bash
# AdrienIT

yum install -y yum install zlib-devel libuuid-devel libmnl-devel gcc make git autoconf autogen automake pkgconfig curl jq nodejs wget git epel-releae nginx nfs-utils
yum update

#bash <(curl -Ss https://my-netdata.io/kickstart.sh) --dont-wait


systemctl enable nfs-server rpcbind
systemctl start nfs-server rpcbind

mkdir /nfsfileshare

mkdir /nfsfileshare/gitea
mkdir /nfsfileshare/maria
mkdir /nfsfileshare/nginx

chmod 777 /nfsfileshare/

echo -e "
/nfsfileshare/gitea   192.168.4.11(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)
/nfsfileshare/maria   192.168.4.12(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)
/nfsfileshare/nginx   192.168.4.13(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)
" > /etc/exports

exportfs -r

systemctl start firewalld
firewall-cmd --permanent --add-service mountd
firewall-cmd --permanent --add-service rpc-bind
firewall-cmd --permanent --add-service nfs
firewall-cmd --add-port=19999/tcp --permanent
firewall-cmd --reload

