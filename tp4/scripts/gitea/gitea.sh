#!/bin/bash
# AdrienIT

yum install -y yum install zlib-devel libuuid-devel libmnl-devel gcc make git autoconf autogen automake pkgconfig curl jq nodejs wget git
yum update

wget -O gitea https://dl.gitea.io/gitea/1.12.5/gitea-1.12.5-linux-amd64

sudo adduser --shell /bin/bash --home /home/git git

mkdir -p /var/lib/gitea/{custom,data,log}
chown -R git:git /var/lib/gitea/
chmod -R 750 /var/lib/gitea/
mkdir /etc/gitea
chown root:git /etc/gitea
chmod 770 /etc/gitea
export GITEA_WORK_DIR=/var/lib/gitea/
cp gitea /usr/local/bin/gitea
chmod +x /usr/local/bin/gitea

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



echo -e "
[Unit]
Description=Gitea (Git with a cup of tea)
After=syslog.target
After=network.target
###
# Don't forget to add the database service requirements
###
#
#Requires=mysql.service
#Requires=mariadb.service
#Requires=postgresql.service
#Requires=memcached.service
#Requires=redis.service
#
###
# If using socket activation for main http/s
###
#
#After=gitea.main.socket
#Requires=gitea.main.socket
#
###
# (You can also provide gitea an http fallback and/or ssh socket too)
#
# An example of /etc/systemd/system/gitea.main.socket
###
##
## [Unit]
## Description=Gitea Web Socket
## PartOf=gitea.service
##
## [Socket]
## Service=gitea.service
## ListenStream=<some_port>
## NoDelay=true
##
## [Install]
## WantedBy=sockets.target
##
###

[Service]
# Modify these two values and uncomment them if you have
# repos with lots of files and get an HTTP error 500 because
# of that
###
#LimitMEMLOCK=infinity
#LimitNOFILE=65535
RestartSec=2s
Type=simple
User=git
Group=git
WorkingDirectory=/var/lib/gitea/
# If using Unix socket: tells systemd to create the /run/gitea folder, which will contain the gitea.sock file
# (manually creating /run/gitea doesn't work, because it would not persist across reboots)
#RuntimeDirectory=gitea
ExecStart=/usr/local/bin/gitea web --config /etc/gitea/app.ini
Restart=always
Environment=USER=git HOME=/home/git GITEA_WORK_DIR=/var/lib/gitea
# If you want to bind Gitea to a port below 1024, uncomment
# the two values below, or use socket activation to pass Gitea its ports as above
###
#CapabilityBoundingSet=CAP_NET_BIND_SERVICE
#AmbientCapabilities=CAP_NET_BIND_SERVICE
###

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/gitea.service

systemctl daemon-reload
systemctl enable gitea
systemctl start gitea


systemctl enable firewalld
systemctl start firewalld
sudo firewall-cmd --add-port=3000/tcp --permanent
sudo firewall-cmd --add-port=19999/tcp --permanent
sudo firewall-cmd --reload

mkdir /mnt/nfsfileshare

mount 192.168.4.14:/nfsfileshare/gitea /mnt/nfsfileshare

#bash <(curl -Ss https://my-netdata.io/kickstart.sh) --dont-wait

useradd backup -u 1003 -s /sbin/nologin

mv /tmp/script_backup_gitea.sh /opt/script_backup_gitea.sh
mv /tmp/backup.service /etc/systemd/system/backup.service

chown backup:root /etc/gitea

chown backup:backup /opt/script_backup_gitea.sh
chmod 755 /opt/script_backup_gitea.sh

chown backup:backup /mnt/nfsfileshare
chmod 755 /mnt/nfsfileshare