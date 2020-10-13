#!/bin/bash
# AdrienIT

yum install -y epel-release
yum install -y nginx

sudo systemctl enable nginx
sudo systemctl start nginx

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

sudo systemctl restart nginx

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


#Auto mount : echo -e "192.168.4.14:/nfsfileshare /mnt/nfsfileshare    nfs     nosuid,rw,sync,hard,intr  0  0" >> /etc/fstab

mkdir /mnt/nfsfileshare

mount 192.168.4.14:/nfsfileshare /mnt/nfsfileshare