#!/bin/bash


# Variable hosts
hosts="
192.168.2.21  node1.tp2.b2
192.168.2.22  node2.tp2.b2
"

# Variable conf nginx
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
        server_name node1.tp2.b2;
        
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

        server_name node1.tp2.b2;
        ssl_certificate /etc/pki/tls/certs/node1.tp2.b2.crt;
        ssl_certificate_key /etc/pki/tls/private/node1.tp2.b2.key;
        
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

# Ajout des hosts
echo -e "${hosts}" > /etc/hosts

# Ouverture des ports
firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --add-port=443/tcp --permanent

# Variable désactivation selinux
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

# Variabe créa script
backup_script="
#!/bin/bash

NOW=$(date +"%m%d%Y_%H%M")

backupdir_files="/opt/backup/*"
backupdir="/opt/backup/"

filename="$(echo "${1}" | awk -F'/' '{print $NF}')"

number_file="$(ls $backupdir | wc -l)"

if [[ $number_file -gt 7 ]]
then
        stat --printf='%Y %n\0' $backupdir_files | sort -z | sed -zn '1s/[^ ]\{1,\} //p' | xargs -0 rm
        echo "Removing oldest file before backup"
        tar -zvcf "${backupdir}/${filename}_${NOW}.tar.gz" "$1"
        echo "backup terminée"
else
        tar -zvcf "${backupdir}/${filename}_${NOW}.tar.gz" "$1"
        echo "backup terminée"
fi
"

# Changement de la conf selinux
echo -e "${selinux}" > /etc/selinux/conf

# Creation user admin + web + backup 
useradd admin -m
usermod -aG wheel admin

useradd web -M -s /sbin/nologin

useradd backup -M -s /sbin/nologin
usermod -aG web backup


# Création du script + ajout de l'exec par l'user backup
mkdir /opt/backup/
touch /opt/backup/backup.sh 
echo -e "${backup_script}" > /opt/backup/backup.sh 
chmod 755 /opt/backup/backup.sh 
chown backup:backup /opt/backup/backup.sh 

# Ajout des crontabs pour les la backup des 2 différents sites
crontab -l > backup1
echo "5 * * * * /opt/backup/backup.sh /srv/site1" >> backup1
crontab backup1
rm backup1

crontab -l > backup2
echo "5 * * * * /opt/backup/backup.sh /srv/site2" >> backup2
crontab backup2
rm backup2

# Je m'excuse à l'avance Léo ptdrrr
# Bon la je créé mon cert et ma key

mkdir /opt/ssl/
echo "-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDN33DDmYRY5ngY
l6srN3uZHMOCQFFKFafy6uVYkQMlA8RA8oSjK565x+k3gtKCNhWX+MWDbBqb4A8N
OSahj08RIuSLnSNCCvp8O15BBHLqm46lo+XKMepQ+URffZgm7sziSEKCUIhPjAA1
G5MXAWi2a9cOoMQuKTXQNeieFQnWcJdlHBuE9b9WC/YoYMtY45dFNgOeaIsmAKqs
YtbNQF1TrjK67StJfD3y2bsShiqrqv8zCHXotOdSbphHvxkL3WOf/aHgsJhTYBK8
z7LLlviC+MvYdBK6J6HCavAQAzyU7wi6AKyUyJIm8oHHdIge7fEHehaFV95rYKg1
y+OqLy8ZAgMBAAECggEBAIpieLUye1Ea0n2NbeSl7fIU8KKcQ0guWG+kT7gB+gAm
kQQrQNdB2fb9lxnWWVRnsIowEexufVBsAxIbaYlOAJL/RmtGnE2nfYqGiavgprJn
EDLtgegxN1VoyPn7PYxmFtjAQ9y+73GxJO6N84iSTOXahXvyuwxgbSjhI9UnRS6b
2JkYjXONmjyGdjX6bynKefJX85cK0rPB44E9NDh5axchITeTsSeQfcDSM8KhV3aZ
Z5kvtAdSC4o1htUssYN46aL1hR82wDrFn67Ikdxh5J6w+0fbWxR7TEkqaobfAfSg
p2Ilqaf7P8q9Sv5Ap/DvfUkkWoeTSVj6BUxofXbFJRECgYEA+emULMpmSy3kxYOC
sKDKJOQB1xx8e/2plQhrWcBW2q0u1q2GvJ8xPSr2ZvUGhXwc4VCtaaaMqAehup+A
q9orVZa5yCcPK/CgT7ZuK83u8iWhACBZ+CXpfJWxlYcjwlrkntN3szTVdCfj+6SM
qreWwbB4jWAELq9cS0/gGBbXv60CgYEA0uM8iPrrPJziUUJ2jdlV7N/pUgZH73u3
MDbbkaKxECTHbYc85r17yrkvm8wQ4LXFXkk9qlEOgSeXBOnZWr4eyYdm0lurmJ+L
5+9oa+NE6kaZrWQ7NeMC2WlgiBHFCZ6oYoEJZAkJxrrYNtbwLHkV3a7rbpDdJ/7N
hWrBGeilap0CgYEAhD3UeasUXB3J27ZOVpaOwNyiGKjrOlUtAj61R4Xer9JKYbDr
Bi6ayIpOXoazz7iwM44UZT6LWXLIYs96L/W/Tof2gPIiNhcbTXL0c1uCYEIHIuD7
mrK9DX7MvJoJExQzu9OcmIiRluhw3Dzjboa9UHrIH886B1Yl2XhH1ZdozPUCgYBr
76BBH+QcjtOK8bCKI43GAkiCEfLpkPGOvNUesh1b/OcRmSFDnAHrHWNPo1+UE5Tk
ECp+rKP22NOD0UjNF/fb//BRhFfMcwSBflh8t8LDAcWQKHfhucHwku20Vxv5M3pN
iGvNBo85ZtJZJyOgL41QfEHFwmFfIhwAyEXzQ86+RQKBgCq7X7JzTuZC/7WvdNgu
xkFJI2NSVAv8R6k4H+xcwaSmKsn3sjQ37PD88wnPMGJlLXzF+YaRmi9YxIatTyDs
504dabtaQn0mTH7b2z69nc5h/pTEyGnsK0suVdRXhET7+1poTRWYHLJsPjXEcG4m
u6dgcnY1h+kmvc+6R1k6NU5G
-----END PRIVATE KEY-----" > /etc/pki/tls/private/node1.tp2.b2.key
chown web:web /etc/pki/tls/private/node1.tp2.b2.key


echo -e "-----BEGIN CERTIFICATE-----
MIIDszCCApugAwIBAgIUWfg5//zbvbjxcX0CVYdWwtMb44QwDQYJKoZIhvcNAQEL
BQAwaTELMAkGA1UEBhMCRlIxEjAQBgNVBAgMCUFxdWl0YWluZTERMA8GA1UEBwwI
Qm9yZGVhdXgxDTALBgNVBAoMBFlub3YxDTALBgNVBAsMBEwzM1QxFTATBgNVBAMM
DG5vZGUxLnRwMi5iMjAeFw0yMDEwMDQxNDA5MzdaFw0yMTEwMDQxNDA5MzdaMGkx
CzAJBgNVBAYTAkZSMRIwEAYDVQQIDAlBcXVpdGFpbmUxETAPBgNVBAcMCEJvcmRl
YXV4MQ0wCwYDVQQKDARZbm92MQ0wCwYDVQQLDARMMzNUMRUwEwYDVQQDDAxub2Rl
MS50cDIuYjIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDN33DDmYRY
5ngYl6srN3uZHMOCQFFKFafy6uVYkQMlA8RA8oSjK565x+k3gtKCNhWX+MWDbBqb
4A8NOSahj08RIuSLnSNCCvp8O15BBHLqm46lo+XKMepQ+URffZgm7sziSEKCUIhP
jAA1G5MXAWi2a9cOoMQuKTXQNeieFQnWcJdlHBuE9b9WC/YoYMtY45dFNgOeaIsm
AKqsYtbNQF1TrjK67StJfD3y2bsShiqrqv8zCHXotOdSbphHvxkL3WOf/aHgsJhT
YBK8z7LLlviC+MvYdBK6J6HCavAQAzyU7wi6AKyUyJIm8oHHdIge7fEHehaFV95r
YKg1y+OqLy8ZAgMBAAGjUzBRMB0GA1UdDgQWBBRx6RciWdoTPaDFAtiD2/f11ynD
mTAfBgNVHSMEGDAWgBRx6RciWdoTPaDFAtiD2/f11ynDmTAPBgNVHRMBAf8EBTAD
AQH/MA0GCSqGSIb3DQEBCwUAA4IBAQCZLT+nONrhyMVxBOHQCywu3O02Qr2oLHzz
cGzQyCAaITquOP15hBXMhFJ1D+1iZ0igCXsJkpT5DbzlkAjkFmov8HM+AOGrzSoA
6Dbr5VobV0lmgwB92MrtnqVGeFaaSfrGsnXRbcFRVPHNNj7U6tvcGysMSlRqKgUZ
wtaY+9b9jz7Ln4fiIPxYFlYc2Ty70Mwq0wR9En95lBMgT5T+1YIoGyCbpqBBTjTy
9xY7XAXoHvXG5F3n/w3f6rqbteyntLHeSfmFw1NmwJgNTfDGj+kE93iHJW3AI7QY
6wTHg8UCtQGhuW6XiBK2I+PQuc6bzZ8eWMEIYfP1Pe7d2b7hCtKT
-----END CERTIFICATE-----" > /etc/pki/tls/certs/node1.tp2.b2.crt
chown web:web /etc/pki/tls/certs/node1.tp2.b2.crt

# Création des fichiers pour le site
mkdir /srv/site1
mkdir /srv/site2
touch /srv/site1/index.html
touch /srv/site2/index.html

echo -e '<h1>Hello from site 1</h1>' | tee /srv/site1/index.html
echo -e '<h1>Hello from site 2</h1>' | tee /srv/site2/index.html


# Ajout des permissions pour le site
chown web:web /srv/site1 -R
chown web:web /srv/site2 -R
chmod 700 /srv/site1 
chmod 700 /srv/site2
chmod 400 /srv/site1/index.html
chmod 400 /srv/site2/index.html

# Install de nginx
yum install -y epel-release, nginx

# Update de la conf nginx
echo -e "${conf_nginx}" > /etc/nginx/nginx.conf

# Start + enable nginx
systemctl start nginx
systemctl enable nginx

# Reload firewall pour l'ouverture des ports
firewall-cmd --reload