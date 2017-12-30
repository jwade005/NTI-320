#!/bin/bash

#configuration of remote Centos 7 server for nagios monitoring
# *****run as root*****

#install and start apache just for monitoring purposes
yum -y install httpd
systemctl enable httpd
systemctl start httpd

#stop html 'warning'
touch /var/www/html/index.html

#install nrpe and nagios plugins
yum -y install nrpe nagios-plugins-all

#add check_mem plugin
yum -y install wget
cd /usr/lib64/nagios/plugins/
wget https://raw.githubusercontent.com/justintime/nagios-plugins/master/check_mem/check_mem.pl
mv check_mem.pl check_mem
chmod +x check_mem
./check_mem -f -w 20 -c 10

#adjust nrpe allowed_hosts
sed -i 's,allowed_hosts=127.0.0.1,allowed_hosts=127.0.0.1\,10.138.0.0/20,g' /etc/nagios/nrpe.cfg
sed -i 's,dont_blame_nrpe=0,dont_blame_nrpe=1,g' /etc/nagios/nrpe.cfg

#adjust nrpe command definitions
sed -i "215i command[check_disk]=\/usr\/lib64\/nagios\/plugins\/check_disk -w 20% -c 10% -p \/dev\/sda1" /etc/nagios/nrpe.cfg
sed -i "216i command[check_procs]=\/usr\/lib64\/nagios\/plugins\/check_procs -w 150 -c 200" /etc/nagios/nrpe.cfg
sed -i "217i command[check_mem]=/usr/lib64/nagios/plugins/check_mem  -f -w 20 -c 10" /etc/nagios/nrpe.cfg

#start the nrpe service
systemctl enable nrpe
systemctl start nrpe
