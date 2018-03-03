#!/bin/bash

#rsyslog server side install script -- run as root on centos7 server

#adjust rsyslog.conf to listen for tcp, udp communication

sed -ie 's/#$ModLoad imudp/$ModLoad imudp/g' /etc/rsyslog.conf

sed -ie 's/#$UDPServerRun 514/$UDPServerRun 514/g' /etc/rsyslog.conf

sed -ie 's/#$ModLoad imtcp/$ModLoad imtcp/g' /etc/rsyslog.conf

sed -ie 's/#$InputTCPServerRun 514/$InputTCPServerRun 514/g' /etc/rsyslog.conf

#restart the rsyslog service

systemctl restart rsyslog.service

#open firewall port 514 to allow tcp, udp communication

firewall-cmd --permanent --zone=public --add-port=514/tcp
firewall-cmd --permanent --zone=public --add-port=514/udp
firewall-cmd --reload

#confirm server listening on port 514

yum -y install net-tools
netstat -antup | grep 514

# support for nagios monitoring

echo "Cloning jwade005's github..."
yum -y install git
git clone https://github.com/jwade005/NTI-320.git

chmod +x /home/Jonathan/NTI-320/automation_scripts/nagios-remote-install-yum.sh
chmod +x /home/Jonathan/NTI-320/automation_scripts/generate_config.sh

./home/Jonathan/NTI-320/automation_scripts/nagios-remote-install-yum.sh

myusername="Jonathan"                         # set this to your username
mynagiosserver="nagios-a"                     # set this to your nagios server name
mycactiserver="cacti-a"                      # set this to your cacti server
myreposerver="yumrepo-a"                       # set this to your repo server
mynagiosserverip="35.197.81.237"                   # set this to the ip address of your nagios server

./home/Jonathan/NTI-320/automation_scripts/generate_config.sh rsyslog-server 10.138.0.7              # code I gave you in a previous assignment that generates a nagios config

gcloud compute scp $1.cfg $myusername@$mynagiosserver:/etc/nagios/conf.d --zone us-west1-a

# gcloud compute scp /home/Jonathan/cacti-a2.cfg Jonathan@nagios-a:/etc/nagios/conf.d --zone us-west1-a

                                      # note: I had to add user my gcloud user to group nagios using usermod -a -G nagios $myusername on my nagios server in order to make this work.
                                      # I also had to chmod 770 /etc/nagios/conf.d


gcloud compute ssh $myusername@$mynagiosserver \
"sudo /usr/sbin/nagios -v /etc/nagios/nagios.cfg" \
| grep "Things look okay - No serious problems" \


if [[ $configstatus ]]; then
   gcloud compute ssh $myusername@$mynagiosserver "sudo systemctl restart nagios"
   echo "$1 has been added to nagios."
else
   echo "There was a problem with the nagios config, please log into $mynagiosserver and run /usr/sbin/nagios -v /etc/nagios/nagios.cfg to figure out where the problem is";
   exit 1;
fi
