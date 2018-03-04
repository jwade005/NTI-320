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
./home/Jonathan/NTI-320/automation_scripts/nagios-remote-install-yum.sh
