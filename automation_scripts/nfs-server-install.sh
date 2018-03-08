#!/bin/bash

#nfs install centos7 server -- run as root

#allow services through the firewall
firewall-cmd --permanent --zone=public --add-service=nfs
firewall-cmd --reload

#install nfs
yum -y install nfs-utils

#start nfs server and services
systemctl enable nfs-server.service
systemctl start nfs-server.service
#systemctl enable nfs-server
systemctl enable nfs-lock
systemctl enable nfs-idmapd
systemctl enable rpcbind
systemctl start rpcbind
systemctl start nfs-lock
systemctl start nfs-idmap


#make directories and adjust ownership and permissions
mkdir /var/dev
chown nfsnobody:nfsnobody /var/dev
chmod 755 /var/dev

mkdir /var/config
chown nfsnobody:nfsnobody /var/config
chmod 755 /var/config

#adjust /etc/exports to allow sharing of folders ***must use internal IPs***
#vi /etc/exports
#add these lines       ***use sed--add uncommented lines-empty file***
echo "/home    *(rw,sync,no_all_squash)
/var/dev       *(rw,sync,no_all_squash)
/var/config    *(rw,sync,no_all_squash)" >> /etc/exports      #(rw sync no_all_squash) * after directory <-- add on all 3 lines


#sed '1 a\/home           10.128.0.3(rw,sync,no_root_squash,no_subtree_check)'\n /etc/exports
#sed '2 a\/var/dev        10.128.0.3(rw,sync,no_subtree_check)'\n /etc/exports
#sed '3 a\/var/config     10.128.0.3(rw,sync,no_subtree_check)'\n /etc/exports

#make changes take effect
exportfs -a
systemctl restart nfs-server

# adds support for nagios monitoring

echo "Cloning jwade005's github..."
yum -y install git
git clone https://github.com/jwade005/NTI-320.git

chmod +x /NTI-320/automation_scripts/add_yum_repo.sh
chmod +x /NTI-320/automation_scripts/nagios-remote-install-yum.sh
./NTI-320/automation_scripts/nagios-remote-install-yum.sh
./NTI-320/automation_scripts/add_yum_repo.sh
