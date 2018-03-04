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
sed -i 's,allowed_hosts=127.0.0.1,allowed_hosts=127.0.0.1\,10.138.0.0\/20,g' /etc/nagios/nrpe.cfg
sed -i 's,dont_blame_nrpe=0,dont_blame_nrpe=1,g' /etc/nagios/nrpe.cfg

#create remote monitoring configuration
cd /etc/nagios/conf.d
touch cacti-a.cfg

echo '# Define a host for the cacti-a machine

define host{
        use                     linux-server
        host_name               cacti-a
        alias                   cacti-a
        address                 10.138.0.2
        }

###############################################################################
###############################################################################
#
# SERVICE DEFINITIONS
#
###############################################################################
###############################################################################

# Define a service to ping the cacti-a-nti320 machine

define service{
        use                             generic-service         ; Name of service template to use
        host_name                       cacti-a
        service_description             PING
        check_command                   check_ping!100.0,20%!500.0,60%
        }

# Define a service to check HTTP on the cacti-a-nti-320 machine.
# Disable notifications for this service by default, as not all users may have HTTP enabled.

define service{
        use                             generic-service         ; Name of service template to use
        host_name                       cacti-a
        service_description             HTTP
        check_command                   check_http
        notifications_enabled           0
        }

# Define a service to check the disk space of the root partition
# on the cacti-a-nti-320 machine.  Warning if < 20% free, critical if
# < 10% free space on partition.

define service{
        use                             generic-service         ; Name of service template to use
        host_name                       cacti-a
        service_description             Root Partition
        check_command			              check_nrpe!check_disk!20%!10%!/
        }

# Define a service to check the number of currently logged in
# users on the cacti-a-nti-320 machine.  Warning if > 20 users, critical
# if > 50 users.

define service{
        use                             generic-service         ; Name of service template to use
        host_name                       cacti-a
        service_description             Current Users
        check_command			              check_nrpe!check_users!20!50
        }


# Define a service to check the number of currently running processes
# on the cacti-a-nti-320 machine.  Warning if > 250 processes, critical if
# > 400 processes.

define service{
        use                             generic-service         ; Name of service template to use
        host_name                       cacti-a
        service_description             Total Processes
        check_command			              check_nrpe!check_procs!250!400!RSZDT
        }

# Define a service to check the load on the cacti-a-nti-320 machine.

define service{
        use                             generic-service         ; Name of service template to use
        host_name                       cacti-a
        service_description             Current Load
        check_command			              check_nrpe!check_load!5.0,4.0,3.0!10.0,6.0,4.0
        }

# Define a service to check SSH on the cacti-a-nti-320 machine.
# Disable notifications for this service by default, as not all users may have SSH enabled.

define service{
        use                             generic-service         ; Name of service template to use
        host_name                       cacti-a
        service_description             SSH
        check_command			              check_ssh
        notifications_enabled		        0
        }
' >> cacti-a-nti320.cfg

echo '# Define a host for the cacti-a machine

define host{
        use                     linux-server
        host_name               yumrepo-a
        alias                   yumrepo-a
        address                 10.138.0.4
        }

###############################################################################
###############################################################################
#
# SERVICE DEFINITIONS
#
###############################################################################
###############################################################################

# Define a service to ping the cacti-a-nti320 machine

define service{
        use                             generic-service         ; Name of service template to use
        host_name                       yumrepo-a
        service_description             PING
        check_command                   check_ping!100.0,20%!500.0,60%
        }

# Define a service to check HTTP on the cacti-a-nti-320 machine.
# Disable notifications for this service by default, as not all users may have HTTP enabled.

define service{
        use                             generic-service         ; Name of service template to use
        host_name                       yumrepo-a
        service_description             HTTP
        check_command                   check_http
        notifications_enabled           0
        }

# Define a service to check the disk space of the root partition
# on the cacti-a-nti-320 machine.  Warning if < 20% free, critical if
# < 10% free space on partition.

define service{
        use                             generic-service         ; Name of service template to use
        host_name                       yumrepo-a
        service_description             Root Partition
        check_command			              check_nrpe!check_disk!20%!10%!/
        }

# Define a service to check the number of currently logged in
# users on the cacti-a-nti-320 machine.  Warning if > 20 users, critical
# if > 50 users.

define service{
        use                             generic-service         ; Name of service template to use
        host_name                       yumrepo-a
        service_description             Current Users
        check_command			              check_nrpe!check_users!20!50
        }


# Define a service to check the number of currently running processes
# on the cacti-a-nti-320 machine.  Warning if > 250 processes, critical if
# > 400 processes.

define service{
        use                             generic-service         ; Name of service template to use
        host_name                       yumrepo-a
        service_description             Total Processes
        check_command			              check_nrpe!check_procs!250!400!RSZDT
        }

# Define a service to check the load on the cacti-a-nti-320 machine.

define service{
        use                             generic-service         ; Name of service template to use
        host_name                       yumrepo-a
        service_description             Current Load
        check_command			              check_nrpe!check_load!5.0,4.0,3.0!10.0,6.0,4.0
        }

# Define a service to check SSH on the cacti-a-nti-320 machine.
# Disable notifications for this service by default, as not all users may have SSH enabled.

define service{
        use                             generic-service         ; Name of service template to use
        host_name                       yumrepo-a
        service_description             SSH
        check_command			              check_ssh
        notifications_enabled		        0
        }
' >> yumrepo-a-nti320.cfg

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
sed -i "215i 'command[check_disk]=\/usr\/lib64\/nagios\/plugins\/check_disk -w 20% -c 10% -p \/dev\/sda1" /etc/nagios/nrpe.cfg
sed -i "216i 'command[check_procs]=\/usr\/lib64\/nagios\/plugins\/check_procs -w 150 -c 200" /etc/nagios/nrpe.cfg

#restart nagios and nrpe services
systemctl restart nrpe
systemctl restart nagios

#verify nagios config
/usr/sbin/nagios -v /etc/nagios/nagios.cfg

#nagios web interface: https://<nagios_server_IP>/nagios
#set up remote host for monitoring
