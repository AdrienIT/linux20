#!/bin/bash
# AdrienIT


# Install necessary packages
yum install -y epel-release nginx vim python3

#Start firewall
systemctl start firewalld

#Add user, change passwd, give permissions
useradd web 
echo web:web | chpasswd
echo -e "%web  ALL=(ALL)       NOPASSWD: /usr/bin/firewall-cmd, /usr/bin/systemctl" >> /etc/sudoers 
usermod -aG web web


#reload systemd
systemctl daemon-reload


#Ajout user backup
useradd backup #-s /sbin/nologin
echo -e "%backup  ALL=(ALL)       NOPASSWD: /opt/script/backup_test.sh, /usr/bin/systemctl" >> /etc/sudoers
usermod -aG backup backup

mkdir /opt/script
mv /tmp/backup_test.sh /opt/script/backup_test.sh
mv /tmp/backup.sh /opt/script/backup.sh
mv /tmp/backup_rota.sh /opt/script/backup_rota.sh


chown backup:backup /opt/script/backup_test.sh
chmod 755 /opt/script/backup_test.sh

chown backup:backup /opt/script/backup.sh
chmod 755 /opt/script/backup.sh

chown backup:backup /opt/script/backup_rota.sh
chmod 755 /opt/script/backup_rota.sh


mkdir /srv/site2
mkdir /srv/site1 
touch /srv/site1/index.html
touch /srv/site2/index.html

mkdir /opt/backup