#!/bin/bash

#configuration of remote Centos 7 server for nagios monitoring
# *****run as root*****

#install and start apache just for monitoring purposes
yum -y install httpd
systemctl enable httpd
systemctl start httpd

#install nrpe and nagios plugins
yum -y install nrpe nagios-plugins-all

#adjust nrpe allowed_hosts
sed -i 's,allowed_hosts=127.0.0.1,allowed_hosts=127.0.0.1,10.138.0.0\/24,g' /etc/nagios/nrpe.cfg
sed -i 's,dont_blame_nrpe=0,dont_blame_nrpe=1,g' /etc/nagios/nrpe.cfg

#adjust nrpe command definitions
sed -i "215i command[check_disk]=\/usr\/lib64\/nagios\/plugins\/check_disk -w 20% -c 10% -p \/dev\/sda1" /etc/nagios/nrpe.cfg
sed -i "216i command[check_procs]=\/usr\/lib64\/nagios\/plugins\/check_procs -w 150 -c 200" /etc/nagios/nrpe.cfg

#start the nrpe service
systemctl enable nrpe
systemctl start nrpe
