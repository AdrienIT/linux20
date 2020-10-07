# TP3 : systemd

## I. Services systemd

### 1. Intro

:sun_with_face:  Utilisez la ligne de commande pour sortir les infos suivantes 

 - afficher le nombre de services systemd dispos sur la machine

```
[vagrant@node1 ~]$ sudo systemctl list-unit-files | wc -l  
250
```


 - afficher le nombre de services systemd actifs ("running") sur la machine

```
[vagrant@node1 ~]$ sudo systemctl list-units | grep -E 'service.*running' | wc -l
16
```

 - afficher le nombre de services systemd qui ont échoué ("failed") ou qui sont inactifs ("exited") sur la machine

```
[vagrant@node1 ~]$ sudo systemctl list-units | grep -E 'service.*exited|service.*failed' | wc -l
22
```


 - afficher la liste des services systemd qui démarrent automatiquement au boot ("enabled")

```
[vagrant@node1 ~]$ sudo systemctl list-unit-files --type service --state enabled,generated | awk 'END{print substr($0,0,2)}'
30
```

### 2. Analyse d'un service

:sun_with_face: Etudiez le service nginx.service

 - déterminer le path de l'unité nginx.service

-> `[vagrant@node1 ~]$ sudo systemctl show -p FragmentPath nginx.service
FragmentPath=/usr/lib/systemd/system/nginx.service`

 - afficher son contenu et expliquer les lignes qui comportent :

 -  - ExecStart

```
[vagrant@node1 ~]$ sudo systemctl cat nginx.service | grep "ExecStart="
ExecStart=/usr/sbin/nginx
```

 -  - ExecStartPre

```
[vagrant@node1 ~]$ sudo systemctl cat nginx.service | grep "ExecStartPre"
ExecStartPre=/usr/bin/rm -f /run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
```

 -  - PIDFile

```
[vagrant@node1 ~]$ sudo systemctl cat nginx.service | grep "PIDFile"
PIDFile=/run/nginx.pid
```

 -  - Type

```
[vagrant@node1 ~]$ sudo systemctl cat nginx.service | grep "Type"
Type=forking
```

 -  - ExecReload

```
[vagrant@node1 ~]$ sudo systemctl cat nginx.service | grep "ExecReload"
ExecReload=/bin/kill -s HUP $MAINPID
```

 -  - Description

```
[vagrant@node1 ~]$ sudo systemctl cat nginx.service | grep "Description"
Description=The nginx HTTP and reverse proxy server
```

 -  - After

```
[vagrant@node1 ~]$ sudo systemctl cat nginx.service | grep "After"
After=network.target remote-fs.target nss-lookup.target
```

 - Listez tous les services qui contiennent la ligne WantedBy=multi-user.target

```
[vagrant@node1 ~]$ grep -Er "WantedBy=multi-user.target" /lib/systemd/system/* | cut -f1 -d":" | awk -F'/' '{print $NF}'
NetworkManager.service
auditd.service
brandbot.path
chrony-wait.service
chronyd.service
cpupower.service
crond.service
ebtables.service
firewalld.service
fstrim.timer
gssproxy.service
irqbalance.service
machines.target
nfs-client.target
nfs-rquotad.service
nfs-server.service
nfs.service
nginx.service
postfix.service
rdisc.service
remote-cryptsetup.target
remote-fs.target
rhel-configure.service
rpc-rquotad.service
rpcbind.service
rsyncd.service
rsyslog.service
sshd.service
tcsd.service
tuned.service
vmtoolsd.service
wpa_supplicant.service
```

## 3. Création d'un service

### A. Serveur web
 Créez une unité de service qui lance un serveur web


Mon systemd : 

```
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
```

Mon user "web" appartient à un groupe qui lui permet d'ouvrir et de fermer les ports (firewalld doit se faire en sudo, donc en gros il appartient à un groupe qui lui permet de faire la commande firewalld en sudo, sans passwd)


Verif : 

```
[vagrant@node1 ~]$ sudo systemctl status web
● web.service - web python serveur
   Loaded: loaded (/usr/lib/systemd/system/web.service; disabled; vendor preset: disabled)
   Active: active (running) since Mon 2020-10-05 10:39:41 UTC; 2s ago
  Process: 26081 ExecStartPre=/usr/bin/sudo /usr/bin/firewall-cmd --add-port=1337/tcp (code=exited, status=0/SUCCESS)
 Main PID: 26088 (python3)
   CGroup: /system.slice/web.service
           └─26088 /usr/bin/python3 -m http.server 1337

Oct 05 10:39:40 node1 systemd[1]: Starting web python serveur...
Oct 05 10:39:40 node1 sudo[26081]:      web : TTY=unknown ; PWD=/ ; USER=root ; COMMAND=/usr/bin/firewall-cmd --add-port=1337/tcp
Oct 05 10:39:41 node1 systemd[1]: Started web python serveur.
```

ET le curl : 

```
[vagrant@node1 ~]$ curl localhost:1337
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Directory listing for /</title>
</head>
<body>
<h1>Directory listing for /</h1>
<hr>
<ul>
<li><a href="bin/">bin@</a></li>
<li><a href="boot/">boot/</a></li>
<li><a href="dev/">dev/</a></li>
<li><a href="etc/">etc/</a></li>
<li><a href="home/">home/</a></li>
<li><a href="lib/">lib@</a></li>
<li><a href="lib64/">lib64@</a></li>
<li><a href="media/">media/</a></li>
<li><a href="mnt/">mnt/</a></li>
<li><a href="opt/">opt/</a></li>
<li><a href="proc/">proc/</a></li>
<li><a href="root/">root/</a></li>
<li><a href="run/">run/</a></li>
<li><a href="sbin/">sbin@</a></li>
<li><a href="srv/">srv/</a></li>
<li><a href="swapfile">swapfile</a></li>
<li><a href="sys/">sys/</a></li>
<li><a href="tmp/">tmp/</a></li>
<li><a href="usr/">usr/</a></li>
<li><a href="var/">var/</a></li>
</ul>
<hr>
</body>
</html>
```

### B. Sauvegarde

Sript lancement vm : 

```bash
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
```
Pour voir ce que fonts mes scripts `backup.sh | backup_test.sh | backup_rota.sh`

C'est dans mon dossier scripts/

#### Timers

Backup.timers : 

```
[vagrant@centos8 ~]$ cat /etc/systemd/system/backup.timer 
[Unit]
Description=Lance la backup toutes les heures

[Timer]
OnCalendar=hourly

[Install]
WantedBy=timers.target
```

Verif : 

```
systemctl list-timers | grep backup
Wed 2020-10-07 11:00:00 UTC  24min left n/a                          n/a       backup.timer                 backup.service
```

:alien: Bonus : Améliorer la sécurité du service de sauvegarde

Avant mes changements : 9.2

Apres mes changements : 5.9, comment j'ai fait : 

NoNewPrivileges=yes
PrivateTmp=yes
PrivateDevices=yes
DevicePolicy=closed
ProtectSystem=strict
ProtectHome=read-only
ProtectControlGroups=yes
ProtectKernelModules=yes
ProtectKernelTunables=yes
RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6 AF_NETLINK
RestrictNamespaces=yes
RestrictRealtime=yes
RestrictSUIDSGID=yes
MemoryDenyWriteExecute=yes
LockPersonality=yes

A faire : GRAND II +  describe ce qu'il y a au dessus  + commenter node1.sh + add dans .md le vagrant file 