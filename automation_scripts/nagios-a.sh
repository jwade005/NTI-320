#!/bin/bash

#nagios core install using yum packages (epel)
# *****run as root*****

#install nagios
yum -y install nagios

#enable and start nagios
systemctl enable nagios
systemctl start nagios

#disable selinux
setenforce 0

#install apache and start the services
yum -y install httpd
systemctl enable httpd
systemctl start httpd

#stop html 'warning'
touch /var/www/html/index.html

#set nagios admin password
htpasswd -b /etc/nagios/passwd nagiosadmin P@ssw0rd1

#install plugins
yum -y install nagios-plugins-all

#install nrpe for remote monitoring and start service
yum -y install nrpe
systemctl enable nrpe
systemctl start nrpe

#restart nagios service
systemctl restart nagios
systemctl restart httpd

#start nagios at reboot
chkconfig nagios on

#adjust nrpe allowed_hosts
sed -i 's,allowed_hosts=127.0.0.1,allowed_hosts=127.0.0.1\,10.138.0.0\/24,g' /etc/nagios/nrpe.cfg
sed -i 's,dont_blame_nrpe=0,dont_blame_nrpe=1,g' /etc/nagios/nrpe.cfg

#isntall nrpe plugin for remote monitoring
yum -y install check_nrpe

#add check_nrpe command definition
echo '# check_nrpe command definition
define command{
        command_name check_nrpe
        command_line $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$
}
' >> /etc/nagios/objects/commands.cfg

#adjust built-in command definitions in nrpe.cfg
sed -i "215i command[check_disk]=\/usr\/lib64\/nagios\/plugins\/check_disk -w 20% -c 10% -p \/dev\/sda1" /etc/nagios/nrpe.cfg
sed -i "216i command[check_procs]=\/usr\/lib64\/nagios\/plugins\/check_procs -w 150 -c 200" /etc/nagios/nrpe.cfg

#restart nagios and nrpe services
systemctl restart nrpe
systemctl restart nagios

#nagios web interface: https:\\<nagios_server_IP>/nagios
#set up remote host for monitoring
