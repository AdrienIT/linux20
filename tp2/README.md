# TP2 : Déploiement automatisé

## I. Deploiement Simple

- Mon vagrantfile : 

```
Vagrant.configure("2") do |config|
  node1_DISK = './node1_DISK.vdi'
  config.vm.box = "centos/7"
  config.vbguest.auto_update = false
  config.vm.box_check_update = false 
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.provision :shell, path: "script.sh", run: 'always'

  config.vm.define "node1" do |node1|
    node1.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024"]
      # Crée le disque, uniquement s'il nexiste pas déjà
      unless File.exist?(node1_DISK)
        vb.customize ['createhd', '--filename', node1_DISK, '--variant', 'Fixed', '--size', 5 * 1024]
      end
      # Attache le disque à la VM
      vb.customize ['storageattach', :id,  '--storagectl', 'IDE', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', node1_DISK]
    end
    node1.vm.box = "centos/7"
    node1.vm.box_url = "https://app.vagrantup.com/centos/boxes/7/versions/2004.01/providers/virtualbox.box"
    node1.vm.hostname = "node1"
    node1.vm.network "private_network", ip: "192.168.2.11", netmask:"255.255.255.0"
  end
end

```

Preuve du fonctionnement : 

```
vagrant@node1 ~]$ free -m
              total        used        free      shared  buff/cache   available
Mem:            990          88         770           6         132         763
Swap:          2047           0        2047
[vagrant@node1 ~]$ sudo fdisk -l | grep /dev/sdb
Disk /dev/sdb: 3221 MB, 3221225472 bytes, 6291456 sectors
[vagrant@node1 ~]$ ip a | grep eth1
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 192.168.2.11/24 brd 192.168.2.255 scope global noprefixroute eth1
[vagrant@node1 ~]$ which vim 
/usr/bin/vim
[vagrant@node1 ~]$ logout
Connection to 127.0.0.1 closed.

╭─ ~/Desktop/Ynov/linux20/tp2/vagrant_tp2 master !2 ?2                     3m 21s 11:45:42 ─╮
╰─❯ vagrant status                                                                         ─╯
Current machine states:

node1                     running (virtualbox)

The VM is running. To stop this VM, you can run `vagrant halt` to
shut it down forcefully, or you can run `vagrant suspend` to simply
suspend the virtual machine. In either case, to restart it again,
simply run `vagrant up`.

╭─ ~/Desktop/Ynov/linux20/tp2/vagrant_tp2 master !2 ?2                            11:48:02 ─╮
╰─❯
```


## II. Re-package

```
╭─ ~/Desktop/Ynov/linux20/tp2/vagrant_tp2 master !2 ?2                     4m 15s 11:59:15 ─╮
╰─❯ vagrant package --output centos7-custom.box                                            ─╯
==> node1: Attempting graceful shutdown of VM...
==> node1: Clearing any previously set forwarded ports...
==> node1: Exporting VM...
==> node1: Compressing package to: /home/adrien/Desktop/Ynov/linux20/tp2/vagrant_tp2/centos7-custom.box

╭─ ~/Desktop/Ynov/linux20/tp2/vagrant_tp2 master !2 ?2                      1m 5s 12:00:25 ─╮
╰─❯ vagrant box add centos7-custom centos7-custom.box                                      ─╯
==> box: Box file was not detected as metadata. Adding it directly...
==> box: Adding box 'centos7-custom' (v0) for provider: 
    box: Unpacking necessary files from: file:///home/adrien/Desktop/Ynov/linux20/tp2/vagrant_tp2/centos7-custom.box
==> box: Successfully added box 'centos7-custom' (v0) for 'virtualbox'!
```

Et voila notre box s'est créée dans notre dossier courant.

## III. Multi-node deployment

(J'ai créer un nouveau dossier pour pas écraser mon ancien VagrantFile)

VagrantFile : 

```
Vagrant.configure("2") do |config|
  config.vm.box = "../centos7-custom.box"
  config.vbguest.auto_update = false
  config.vm.box_check_update = false 
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.define "node1" do |node1|
    # remarquez l'utilisation de 'node1.' défini sur la ligne au dessus
    node1.vm.network "private_network", ip: "192.168.56.11"
    node1.vm.hostname = "node1.tp2.b2"

    node1.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024"]
    end
  end

  # Config une première VM "node2"
  config.vm.define "node2" do |node2|
    # remarquez l'utilisation de 'node2.' défini sur la ligne au dessus
    node2.vm.network "private_network", ip: "192.168.56.12"
    node2.vm.hostname = "node2.tp2.b2"

    node2.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", "512"]
    end
  end
end

```


Preuve du fonctionnement : 

```
╭─ ~/Desktop/Ynov/linux20/tp2/vagrant_tp2/multi-node master !2 ?2          1m 10s 12:09:38 ─╮
╰─❯ vagrant status                                                                         ─╯
Current machine states:

node1                     running (virtualbox)
node2                     running (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.

[vagrant@node2 ~]$ free -m
              total        used        free      shared  buff/cache   available
Mem:            486         105         285           4          95         364
Swap:          2047           0        2047
[vagrant@node2 ~]$ logout
Connection to 127.0.0.1 closed.

╭─ ~/Desktop/Ynov/linux20/tp2/vagrant_tp2/multi-node master !2 ?2             11s 12:15:22 ─╮
╰─❯ vagrant ssh node1                                                                      ─╯
Last login: Tue Sep 29 10:11:19 2020 from 10.0.2.2
[vagrant@node1 ~]$ free -m
              total        used        free      shared  buff/cache   available
Mem:            990         118         774           6          97         750
Swap:          2047           0        2047
[vagrant@node1 ~]$
```

## IV. Automation here we (slowly) come

Déso léo (tu verras plus tard pourquoi ptdrr)

Script node1 : 

```
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
```

Script node2:

```
#!/bin/bash

# Ajout des hosts
hosts="
192.168.2.21  node1.tp2.b2
192.168.2.22  node2.tp2.b2
"
echo -e "${hosts}" > /etc/hosts

# Ajout route vers node1
ip route add 192.168.2.0/24 via 192.168.2.22 dev eth1


# Ajout de mon cert vers le ca-trust permettant l'acces en https au site1
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
-----END CERTIFICATE-----" > /etc/pki/ca-trust/source/anchors/node1.tp2.b2.crt

# reload des ca-trust
update-ca-trust
```
 
Preuve du bon fontionnement : 

```
[vagrant@node2 ~]$ curl -L https://node1.tp2.b2/
<h1>Hello from site 1</h1>
```

Et boum magique