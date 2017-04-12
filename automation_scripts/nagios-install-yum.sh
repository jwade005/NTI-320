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

#create remote monitoring configuration
cd /etc/nagios/conf.d
touch test-1-nti320.cfg

echo '# Define a host for the test-1-nti320 machine

define host{
        use                     linux-server            ; Name of host template to use
                                                        ; This host definition will inherit all variables that are defined
                                                        ; in (or inherited by) the linux-server host template definition.
        host_name               test-1
        alias                   test-1-nti320
        address                 10.138.0.3
        }

###############################################################################
###############################################################################
#
# SERVICE DEFINITIONS
#
###############################################################################
###############################################################################

# Define a service to ping the test-1-nti320 machine

define service{
        use                             generic-service         ; Name of service template to use
        host_name                       test-1
        service_description             PING
        check_command                   check_ping!100.0,20%!500.0,60%
        }

# Define a service to check HTTP on the test-1-nti-320 machine.
# Disable notifications for this service by default, as not all users may have HTTP enabled.

define service{
        use                             generic-service         ; Name of service template to use
        host_name                       test-1
        service_description             HTTP
        check_command                   check_http
        notifications_enabled           0
        }

# Define a service to check the disk space of the root partition
# on the test-1-nti-320 machine.  Warning if < 20% free, critical if
# < 10% free space on partition.

define service{
        use                             generic-service         ; Name of service template to use
        host_name                       test-1
        service_description             Root Partition
        check_command			              check_nrpe!check_disk!20%!10%!/
        }

# Define a service to check the number of currently logged in
# users on the test-1-nti-320 machine.  Warning if > 20 users, critical
# if > 50 users.

define service{
        use                             generic-service         ; Name of service template to use
        host_name                       test-1
        service_description             Current Users
        check_command			              check_nrpe!check_users!20!50
        }


# Define a service to check the number of currently running processes
# on the test-1-nti-320 machine.  Warning if > 250 processes, critical if
# > 400 processes.

define service{
        use                             generic-service         ; Name of service template to use
        host_name                       test-1
        service_description             Total Processes
        check_command			              check_nrpe!check_procs!250!400!RSZDT
        }

# Define a service to check the load on the test-1-nti-320 machine.

define service{
        use                             generic-service         ; Name of service template to use
        host_name                       test-1
        service_description             Current Load
        check_command			              check_nrpe!check_load!5.0,4.0,3.0!10.0,6.0,4.0
        }

# Define a service to check SSH on the test-1-nti-320 machine.
# Disable notifications for this service by default, as not all users may have SSH enabled.

define service{
        use                             generic-service         ; Name of service template to use
        host_name                       test-1
        service_description             SSH
        check_command			              check_ssh
        notifications_enabled		        0
        }


#To check services defined here you need to install nagios plugins and nrpe on remote host and define
#the commands in /etc/nagios/objects/commands.cfg
#        command_name    check_load
#        command_line    $USER1$/check_load -w $ARG1$ -c $ARG2$
#        }

# check_disk command definition
#define command{
#        command_name    check_disk
#        command_line    $USER1$/check_disk -w $ARG1$ -c $ARG2$ -p $ARG3$
#        }

# check_procs command definition
#define command{
#        command_name    check_procs
#        command_line    $USER1$/check_procs -w $ARG1$ -c $ARG2$ -s $ARG3$
#        }

# check_users command definition
#define command{
#        command_name    check_users
#        command_line    $USER1$/check_users -w $ARG1$ -c $ARG2$
#        }
' >> test-1-nti320.cfg

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
