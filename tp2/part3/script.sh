#!/bin/bash

hosts="
192.168.2.21  node1.tp2.b2
192.168.2.22  node2.tp2.b2
"

conf_nginx="
worker_processes 1;
error_log nginx_error.log;
pid /run/nginx.pid;
user web;

events {
    worker_connections 1024;
}

http {
    server {
        listen 80;
        server_name node1.tp1.b2;
        
        location / {
              return 301 /site1;
        }

        location /site1 {
            alias /srv/site1;
        }

        location /site2 {
            alias /srv/site2;
        }
    }
    server {
        listen 443 ssl;

        server_name node1.tp1.b2;
        ssl_certificate /etc/pki/tls/certs/node1.tp1.b2.crt;
        ssl_certificate_key /etc/pki/tls/private/node1.tp1.b2.key;
        
        location / {
              return 301 /site1;
        }

        location /site1 {
            alias /srv/site1;
        }

        location /site2 {
            alias /srv/site2;
        }
    }
}
"

echo ${hosts} > /etc/hosts


firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --add-port=443/tcp --permanent

selinux="
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
# enforcing - SELinux security policy is enforced.
# permissive - SELinux prints warnings instead of enforcing.
# disabled - No SELinux policy is loaded.
SELINUX=permissive
# SELINUXTYPE= can take one of these two values:
# default - equivalent to the old strict and targeted policies
# mls     - Multi-Level Security (for military and educational use)
# src     - Custom policy built from source
SELINUXTYPE=default

# SETLOCALDEFS= Check local definition changes
SETLOCALDEFS=0
"

echo ${selinux} > /etc/selinux/conf

useradd admin -m
usermod -aG wheel admin

useradd web -M -s /sbin/nologin

mkdir /opt/ssl/

openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout /opt/ssl/server.key -out /opt/ssl/server.crt -subj "/C=FR/ST=Aquitaine/L=Bordeaux/O=Ynov/OU=L33T/CN=ynov.com"

mv /opt/ssl/server.key /etc/pki/tls/private/node1.tp1.b2.key
chmod 400 /etc/pki/tls/private/node1.tp1.b2.key
chown web:web /etc/pki/tls/private/node1.tp1.b2.key

mv /opt/ssl/server.crt /etc/pki/tls/certs/node1.tp1.b2.crt
chmod 444 /etc/pki/tls/certs/node1.tp1.b2.crt
chown web:web /etc/pki/tls/certs/node1.tp1.b2.crt

mkdir /srv/site1
mkdir /srv/site2
touch /srv/site1/index.html
touch /srv/site2/index.html

echo '<h1>Hello from site 1</h1>' | tee /srv/site1/index.html
echo '<h1>Hello from site 2</h1>' | tee /srv/site2/index.html

chown web:web /srv/site1 -R
chmod 700 /srv/site1 
chmod 700 /srv/site2
chmod 400 /srv/site1/index.html
chmod 400 /srv/site2/index.html

yum install -y epel-release, nginx

systemctl start nginx
systemctl enable nginx

echo ${conf_nginx} > /etc/nginx/nginx.conf