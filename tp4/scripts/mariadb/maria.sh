#!/bin/bash
# AdrienIT

yum install -y yum install zlib-devel libuuid-devel libmnl-devel gcc make git autoconf autogen automake pkgconfig curl jq nodejs wget git mariadb-server
yum update -y

#bash <(curl -Ss https://my-netdata.io/kickstart.sh) --dont-wait
systemctl start firewalld
firewall-cmd --add-port=19999/tcp --permanent
firewall-cmd --add-port=3306/tcp --permanent

sudo systemctl enable mariadb.service
sudo systemctl start mariadb.service

# log gitea web root:root
# log bdd : gitea:gitea ou gitea + enter

echo "bind-address = 192.168.4.12" >> /etc/my.cnf


systemctl restart mariadb.service

mysql -h "localhost" "--user=root" "--password=" -e \
	"SET old_passwords=0;" -e \
	"CREATE USER 'gitea'@'192.168.4.12' IDENTIFIED BY 'gitea';" -e \
	"SET PASSWORD FOR 'gitea'@'192.168.4.12' = PASSWORD('gitea');" -e \
	"CREATE DATABASE giteadb CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_unicode_ci';" -e \
	"grant all privileges on giteadb.* to 'gitea'@'192.168.4.%' identified by 'gitea' with grant option;" -e \
	"FLUSH PRIVILEGES;"



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

firewall-cmd --reload

mkdir /mnt/nfsfileshare

mount 192.168.4.14:/nfsfileshare/maria /mnt/nfsfileshare

mv /tmp/backup_sql.sh /opt/backup_sql.sh
mv /tmp/backup.service /etc/systemd/system/backup.service
chmod a+x /opt/backup_sql.sh