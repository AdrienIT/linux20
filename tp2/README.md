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