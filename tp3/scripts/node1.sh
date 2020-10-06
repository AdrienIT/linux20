#!/bin/bash
# AdrienIT

yum install -y epel-release, nginx, vim, python3

#useradd web 

#groupadd perm 

#echo -e "perm  ALL=(ALL)       NOPASSWD: /usr/bin/firewall-cmd" >> /etc/sudoers 

#usermod -aG perm web

#touch /lib/systemd/system/web.service

#echo -e "
#[Unit]
#    Description=web python serveur
#
#[Service]
#    Type=simple
#    PIDFile=/var/run/web.pid
#    ExecStartPre=/usr/bin/sudo /usr/bin/firewall-cmd --add-port=1337/tcp
#    ExecStart=/usr/bin/python3 -m http.server ${SuperPortHack}
#    ExecStop=/usr/bin/sudo /usr/bin/firewall-cmd --remove-port=1337/tcp
#    User=web
#    Environment=SuperPortHack=1337
#[Install]
#    WantedBy=multi-user.target
#" > /lib/systemd/system/web.service

#systemctl daemon-reload



