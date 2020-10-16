#!/bin/bash
# AdrienIT

yum install -y yum install zlib-devel libuuid-devel libmnl-devel gcc make git autoconf autogen automake pkgconfig curl jq nodejs wget git epel-releae nginx
yum update

yum install -y epel-release
yum install -y nginx

systemctl start firewalld
firewall-cmd --add-port=19999/tcp --permanent
firewall-cmd --add-port=80/tcp --permanent

sudo systemctl enable nginx
sudo systemctl start nginx

mv /tmp/script_backup_nginx.sh /opt/script_backup_nginx.sh
mv /tmp/backup.service /etc/systemd/system/backup.service

echo -e "
127.0.0.1       nginx   nginx
127.0.0.1       node1   node1
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.4.11  gitea" > /etc/hosts

echo -e "
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;
events {
    worker_connections 1024;
}
http {
    server {
        listen 80;
        server_name gitea;
        location / {
                proxy_pass http://gitea:3000;
        }
    }
}" > /etc/nginx/nginx.conf

systemctl restart nginx

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


firewall-cmd --reload

#Auto mount : echo -e "192.168.4.14:/nfsfileshare /mnt/nfsfileshare    nfs     nosuid,rw,sync,hard,intr  0  0" >> /etc/fstab

mkdir /mnt/nfsfileshare

mount 192.168.4.14:/nfsfileshare/nginx /mnt/nfsfileshare

#bash <(curl -Ss https://my-netdata.io/kickstart.sh) --dont-wait

useradd backup -u 1003 -s /sbin/nologin

echo -e "%backup  ALL=(ALL)       NOPASSWD: /opt/script_backup_nginx.sh, /usr/bin/systemctl" >> /etc/sudoers
usermod -aG backup backup

chown backup:backup /opt/script_backup_nginx.sh
chmod 755 /opt/script_backup_nginx.sh

chown backup:backup /mnt/nfsfileshare
chmod 755 /mnt/nfsfileshare