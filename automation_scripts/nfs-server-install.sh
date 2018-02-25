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

chmod +x /home/Jonathan/NTI-320/automation_scripts/nagios-remote-install.sh
chmod +x /home/Jonathan/NTI-320/automation_scripts/generate_config.sh

./home/Jonathan/NTI-320/automation_scripts/nagios-remote-install.sh

myusername="Jonathan"                         # set this to your username
mynagiosserver="nagios-a"                     # set this to your nagios server name
mycactiserver="cacti-a"                      # set this to your cacti server
myreposerver="yumrepo-a"                       # set this to your repo server
mynagiosserverip="35.197.81.237"                   # set this to the ip address of your nagios server

./home/Jonathan/NTI-320/automation_scripts/generate_config.sh ldap-server 10.138.0.8              # code I gave you in a previous assignment that generates a nagios config

gcloud compute scp $1.cfg $myusername@$mynagiosserver:/etc/nagios/conf.d --zone us-west1-a

# gcloud compute scp /home/Jonathan/cacti-a2.cfg Jonathan@nagios-a:/etc/nagios/conf.d --zone us-west1-a

                                      # note: I had to add user my gcloud user to group nagios using usermod -a -G nagios $myusername on my nagios server in order to make this work.
                                      # I also had to chmod 770 /etc/nagios/conf.d


gcloud compute ssh $myusername@$mynagiosserver \
"sudo /usr/sbin/nagios -v /etc/nagios/nagios.cfg" \
| grep "Things look okay - No serious problems" \


if [[ $configstatus ]]; then
   gcloud compute ssh $myusername@$mynagiosserver "sudo systemctl restart nagios" --zone us-west1-a
   echo "$1 has been added to nagios."
else
   echo "There was a problem with the nagios config, please log into $mynagiosserver and run /usr/sbin/nagios -v /etc/nagios/nagios.cfg to figure out where the problem is";
   exit 1;
fi
