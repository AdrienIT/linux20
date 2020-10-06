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


# Créa Unit systemd
touch /lib/systemd/system/web.service

echo -e "
[Unit]
    Description=web python serveur

[Service]
    Type=simple
    PIDFile=/var/run/web.pid
    ExecStartPre=/usr/bin/sudo /usr/bin/firewall-cmd --add-port=1337/tcp
    ExecStart=/usr/bin/python3 -m http.server ${SuperPortHack}
    ExecStop=/usr/bin/sudo /usr/bin/firewall-cmd --remove-port=1337/tcp
    User=web
    Environment=SuperPortHack=1337
[Install]
    WantedBy=multi-user.target
" > /lib/systemd/system/web.service

#reload systemd
systemctl daemon-reload


#Ajout user backup

useradd backup -s /sbin/nologin
echo -e "%backup  ALL=(backup) /opt/script/backup_test.sh, /opt/script/backup.sh, /opt/script/backup_rota.sh, /usr/bin/systemctl       NOPASSWD: /opt/script/backup_test.sh, /opt/script/backup.sh, /opt/script/backup_rota.sh, /usr/bin/systemctl" >> /etc/sudoers 
usermod -aG backup backup

#script test
echo -e "Script


" > /opt/script/backup.sh

chown backup:backup /opt/script/backup_test.sh /opt/script/backup.sh /opt/script/backup_rota.sh
chmod 755 /opt/script/backup_test.sh /opt/script/backup.sh /opt/script/backup_rota.sh
