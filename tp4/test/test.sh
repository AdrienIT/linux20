#!/bin/bash
# AdrienIT

## REPACKAGING

### packages
yum install -y yum install zlib-devel libuuid-devel libmnl-devel gcc make git autoconf autogen automake pkgconfig curl jq nodejs wget git mariadb-server tree
yum update -y

#netdata
bash <(curl -Ss https://my-netdata.io/kickstart.sh) --dont-wait

sed -i "/DISCORD_WEBHOOK_URL=/c\DISCORD_WEBHOOK_URL='https://discord.com/api/webhooks/766743602519998464/O6oMDtxBqb4Gw3CLZzkT5TNDT4ZWIUrLGcC_bz8DXiM0SyU47HYeACI-Co-I9Klnp5-a'" /usr/lib/netdata/conf.d/health_alarm_notify.conf

#hosts

echo -e "
127.0.0.1  localhost
192.168.4.11  gitea
192.168.4.12  mariadb
192.168.4.13  nginx
192.168.4.14  nfs

" > /etc/hosts

#selinux
setenforce 0

echo -e "
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=disabled
# SELINUXTYPE= can take one of three values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected. 
#     mls - Multi Level Security protection.
SELINUXTYPE=minimum
" > /etc/selinux/conf


#basics of systemctl

systemctl enable firewalld
systemctl start firewalld
sudo firewall-cmd --add-port=19999/tcp --permanent
sudo firewall-cmd --reload


#user full right
echo -e "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers