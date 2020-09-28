# TP1 : Déploiement classique

## I. Setup serveur Web

:sun_with_face: Faites en sorte que : 

- NGINX servent deux sites web, chacun possède un fichier unique index.html

```
[adrien@node1 ~]$ curl -L node1.tp1.b2/site1
site1
[adrien@node1 ~]$ curl -L node1.tp1.b2/site2
site2
[adrien@node1 ~]$
```

 - les sites web doivent se trouver dans /srv/site1 et /srv/site2
 - les permissions sur ces dossiers doivent être le plus restrictif possible
 - ces dossiers doivent appartenir à un utilisateur et un groupe spécifique
```
[adrien@node1 ~]$ ls -al /srv/
total 0
drwxrwxrwx.  4 web  web   32 24 sept. 10:48 .
dr-xr-xr-x. 17 root root 242 23 sept. 14:26 ..
drwx------.  2 web  web   24 24 sept. 11:43 site1
drwx------.  2 web  web   24 24 sept. 11:43 site2
[adrien@node1 ~]$
```

Ici, on voit bien que les fichiers appartiennent bien à l'user web et au groupe web.



 - NGINX doit utiliser un utilisateur dédié que vous avez créé à cet effet
 
```
[adrien@node1 ~]$ sudo cat /etc/nginx/nginx.conf | grep user
user web;
```

 - les sites doivent être servis en HTTPS sur le port 443 et en HTTP sur le port 80

PAs réussi, non compréhensison du fichier de conf

:sun_with_face: Prouver que la machine node2 peut joindre les deux sites web.
```
[adrien@node2 ~]$ curl -L node1.tp1.b2/site2
<!doctype html>
<html>
  <head>
    <title>This is the title of the webpage!</title>
  </head>
  <body>
    <p>site2</p>
  </body>
</html>
[adrien@node2 ~]$
```

## II. Script de sauvegarde

:sun_with_face:  Ecrire un script.

Hoplé:

```bash
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
```

:sun_with_face: Crontab pour que ça se fasse toutes les heures : 

```
sudo crontab -e -u backup

5 * * * * /home/backup/tp1_backup.sh /srv/site1
5 * * * * /home/backup/tp1_backup.sh /srv/site2
```

:sun_with_face: Restauration site antérieur : 

C'est assez simple, il faudra juste decompresser l'archive à la place du site que l'on voudra restaurer avec la commande `tar -zxvf Nom_de_larchive.tar.gz`

:alien: SystemD

```
[adrien@node1 ~]$ ls -alt1 /opt/backup/
total 16
drwxr-xr-x. 2 backup backup 168 24 sept. 12:36 .
-rw-r--r--. 1 backup backup  45 24 sept. 12:36 _09242020_1236.tar.gz
-rw-r--r--. 1 backup backup  45 24 sept. 12:35 _09242020_1235.tar.gz
-rw-r--r--. 1 backup backup 396 24 sept. 11:07 site1_09242020_1107.tar.gz
-rw-r--r--. 1 root   root     0 24 sept. 11:07 4
-rw-r--r--. 1 root   root     0 24 sept. 11:07 3
-rw-r--r--. 1 root   root     0 24 sept. 11:07 2
-rw-r--r--. 1 root   root     0 24 sept. 11:07 1
-rw-r--r--. 1 backup backup 396 24 sept. 11:05 site1_09242020_1105.tar.gz
drwxr-xr-x. 3 root   root    20 24 sept. 09:45 ..

```

On vient ensuite lancer notre "systemctl start backup"

```
[adrien@node1 ~]$ ls -alt1 /opt/backup/
total 24
drwxr-xr-x. 2 backup backup 222 24 sept. 16:05 .
-rw-r--r--. 1 backup backup  45 24 sept. 16:05 site2_09242020_1605.tar.gz
-rw-r--r--. 1 backup backup  45 24 sept. 16:05 site1_09242020_1605.tar.gz
-rw-r--r--. 1 backup backup  45 24 sept. 15:52 _09242020_1552.tar.gz
-rw-r--r--. 1 backup backup  45 24 sept. 12:36 _09242020_1236.tar.gz
-rw-r--r--. 1 backup backup  45 24 sept. 12:35 _09242020_1235.tar.gz
-rw-r--r--. 1 backup backup 396 24 sept. 11:07 site1_09242020_1107.tar.gz
-rw-r--r--. 1 root   root     0 24 sept. 11:07 4
-rw-r--r--. 1 root   root     0 24 sept. 11:07 3
-rw-r--r--. 1 root   root     0 24 sept. 11:07 2
drwxr-xr-x. 3 root   root    20 24 sept. 09:45 ..
[adrien@node1 ~]$ date
jeu. sept. 24 16:06:31 CEST 2020
[adrien@node1 ~]$ 

```

On remarque que les 2 fichiers les plus anciens : "1" et "site1_09242020_1105.tar.gz" on étaient supprimés et on était remplacés par "site1_09242020_1605.tar.gz" et "site2_09242020_1605.tar.gz"

(Bien évidement le user qui lance la commande pour backup est notre user 'backup')

## III. Monitoring, alerting

- Mise en place netdata

Bon beh c'est assez simple : 

`bash <(curl -Ss https://my-netdata.io/kickstart.sh) --no-updates`

On vient check si ça a bien work : 

 - Config netdata pour qu'il envoie des alertes dans un salon : 

On vient d'abord chopper notre webook (parametre du channel, intégrations, créer un webhook)


On vient ensuite modifié ce fichier de conf : 

`/etc/netdata/health_alarm_notify.conf`


On y met ça : 

```
###############################################################################
# sending discord notifications

# note: multiple recipients can be given like this:
#                  "CHANNEL1 CHANNEL2 ..."

# enable/disable sending discord notifications
SEND_DISCORD="YES"

# Create a webhook by following the official documentation -
# https://support.discordapp.com/hc/en-us/articles/228383668-Intro-to-Webhooks
DISCORD_WEBHOOK_URL="https://discordapp.com/api/webhooks/XXXXXXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

# if a role's recipients are not configured, a notification will be send to
# this discord channel (empty = do not send a notification for unconfigured
# roles):
DEFAULT_RECIPIENT_DISCORD="alarms"
```

On remplace le webhook, par le notre, et voila c'est fait.

Voila ce que ça donne :

![](https://i.imgur.com/F5sv3z5.png)
