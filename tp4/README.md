# TP4 : Déploiement multi-noeud

## Rendu TP : 

### Schéma du repo : 

```
.
├── centos7-custom.box
├── scripts
│   ├── gitea
│   │   ├── backup.service
│   │   ├── gitea.sh
│   │   └── script_backup_gitea.sh
│   ├── mariadb
│   │   ├── backup.service
│   │   ├── backup_sql.sh
│   │   └── maria.sh
│   ├── nfs
│   │   └── nfs.sh
│   ├── nginx
│   │   ├── backup.service
│   │   ├── nginx.sh
│   │   └── script_backup_nginx.sh
│   └── repackage.sh
└── Vagrantfile
```


#### Conseil de lancement : 

start nfs en premier puis le reste sinon ya un "no route to host" qui pop lors du `mount`

#### Notes utiles : 

user+pwd gitea : gitea:gitea
Pas de pwd user root mysql

### Vagrant file : 

```bash
Vagrant.configure("2") do |config|
  config.vm.box = "centos7-custom"
  config.vbguest.auto_update = false
  config.vm.box_check_update = false 
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.define "gitea" do |gitea|
    gitea.vm.network "private_network", ip: "192.168.4.11"
    gitea.vm.hostname = "gitea"
    gitea.vm.provision "file", source: "scripts/gitea/script_backup_gitea.sh", destination: "/tmp/script_backup_gitea.sh"
    gitea.vm.provision "file", source: "scripts/gitea/backup.service", destination: "/tmp/backup.service"
    gitea.vm.provision :shell, path: "scripts/gitea/gitea.sh", run: 'always'
  end

  config.vm.define "maria" do |maria|
    maria.vm.network "private_network", ip: "192.168.4.12"
    maria.vm.hostname = "maria"
    maria.vm.provision "file", source: "scripts/mariadb/backup_sql.sh", destination: "/tmp/backup_sql.sh"
    maria.vm.provision "file", source: "scripts/mariadb/backup.service", destination: "/tmp/backup.service"
    maria.vm.provision :shell, path: "scripts/mariadb/maria.sh", run: 'always'
  end

  config.vm.define "nginx" do |nginx|
    nginx.vm.network "private_network", ip: "192.168.4.13"
    nginx.vm.hostname = "nginx"
    nginx.vm.provision "file", source: "scripts/nginx/script_backup_nginx.sh", destination: "/tmp/script_backup_nginx.sh"
    nginx.vm.provision "file", source: "scripts/nginx/backup.service", destination: "/tmp/backup.service"
    nginx.vm.provision :shell, path: "scripts/nginx/nginx.sh", run: 'always'
  end

  config.vm.define "nfs" do |nfs|
    nfs.vm.network "private_network", ip: "192.168.4.14"
    nfs.vm.hostname = "nfs"
    nfs.vm.provision :shell, path: "scripts/nfs/nfs.sh", run: 'always'
  end
end
```

### Liste des hosts

| name | IP   | Role |
| ---- | ---- | ---- |
| gitea|192.168.4.11|Serveur hebergeant le Gitea|
| maria|192.168.4.12|Serveur hebergeant  base de données|
| nginx|192.168.4.13|Serveur Nginx agissant comme reverse-proxy|
| nfs|192.168.4.14|Serveur de fichiers commun (utilisé pour save les backups)|
