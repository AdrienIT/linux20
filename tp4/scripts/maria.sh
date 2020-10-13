#!/bin/bash
# AdrienIT

yum install -y mariadb-server
sudo systemctl enable mariadb.service
sudo systemctl start mariadb.service

# log gitea web root:root
# log bdd : gitea:gitea ou gitea + enter
mysql -u root -p
SET PASSWORD FOR 'gitea'@'192.168.4.12' = PASSWORD('gitea');

echo -e "
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=permissive
# SELINUXTYPE= can take one of three values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected. 
#     mls - Multi Level Security protection.
SELINUXTYPE=minimum
" > /etc/selinux/conf

echo -e "192.168.4.14:/nfsfileshare /mnt/nfsfileshare    nfs     nosuid,rw,sync,hard,intr  0  0" >> /etc/fstab

mkdir /mnt/nfsfileshare