#!/bin/bash
# AdrienIT

yum install -y epel-release
yum install -y nginx

firewall-cmd --add-port=80/tcp --permanent

sudo systemctl enable nginx
sudo systemctl start nginx

mv /tmp/script_backup_nginx.sh /opt/script_backup_nginx.sh
mv /tmp/backup.service /etc/systemd/system/backup.service

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