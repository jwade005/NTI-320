#!/bin/bash

#nagios core server install from source
#***** run as root *****

#clone jwade005's github
yum -y install git
git clone https://github.com/jwade005/NTI-320.git /tmp/NTI-320


yum install -y wget httpd php gcc glibc glibc-common gd gd-devel make net-snmp unzip openssl-devel

setenforce 0

cd /tmp

#this will download Nagios Core and plugins

wget http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-4.3.1.tar.gz
wget http://nagios-plugins.org/download/nagios-plugins-2.1.4.tar.gz

#add users and groups for nagios processes

useradd nagios
groupadd nagcmd
usermod -a -G nagcmd nagios
usermod -a -G nagios,nagcmd apache

#extract packages

tar zxvf nagios-4.3.1.tar.gz
tar zxvf nagios-plugins-2.1.4.tar.gz

#cd to nagios directory and install the packages
cd nagios-4.3.1

./configure --with-command-group=nagcmd

make all
make install
make install-init
make install-config
make install-commandmode
make install-webconf
cp -R contrib/eventhandlers/ /usr/local/nagios/libexec/
chown -R nagios:nagios /usr/local/nagios/libexec/eventhandlers
/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

#start the nagios and httpd services

/etc/init.d/nagios start
/etc/init.d/httpd start

#create user for web interface

htpasswd –c /usr/local/nagios/etc/htpasswd.users nagiosadmin P@ssw0rd1

#install nagios plugins

cd /tmp/nagios-plugins-2.1.4
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make
make install

#the following commands will register the Nagios daemon to be run upon system startup
chkconfig --add nagios
chkconfig --level 35 nagios on
chkconfig --add httpd
chkconfig --level 35 httpd on

#run pre-flight check on configuration data
/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg


#install nrpe-3
cd ~
wget https://github.com/NagiosEnterprises/nrpe/archive/3.0.1.tar.gz

#extract nrpe-3
tar xvf 3.0.1.tar.gz
cd nrpe-3.0.1

#configure nrpe-3
./configure --enable-command-args --with-nagios-user=nagios --with-nagios-group=nagios --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu

#build and install NRPE
make all
make install

#add firewall rules for nrpe communication over tcp:5666
firewall-cmd --zone=public --add-port=5666/tcp
firewall-cmd --zone=public --add-port=5666/tcp --permanent

#edit nrpe.cfg file
sed -i '/^allowed_hosts=/s/$/,10.138.0.0\/24/' /usr/local/nagios/etc/nrpe.cfg
sed -i 's/^dont_blame_nrpe=.*/dont_blame_nrpe=1/g' /usr/local/nagios/etc/nrpe.cfg

#add support for nrpe and other commands in commands.cfg
echo "define command{
  command_name check_nrpe
  command_line $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$
  }

# 'check_load' comand defintion
define command{
	command_name	check_load
	command_line $USER1$/check_load -w $ARG1$ -c $ARG2$
	}

# 'check_disk' command definition
define command{
  command_name    check_disk
  command_line    $USER1$/check_disk -w $ARG1$ -c $ARG2$ -p $ARG3$
  }

# 'check_procs' command definition
define command{
  command_name    check_procs
  command_line    $USER1$/check_procs -w $ARG1$ -c $ARG2$ -s $ARG3$
  }

# 'check_users' command definition
define command{
  command_name    check_users
  command_line    $USER1$/check_users -w $ARG1$ -c $ARG2$
  }" >> /usr/local/nagios/etc/objects/commands.cfg

#open server directory for monitoring configurations
sed -i "s,#cfg_dir=\/usr\/local\/nagios\/etc\/servers,cfg_dir=\/usr\/local\/nagios\/etc\/servers,g" /usr/local/nagios/etc/nagios.cfg

#make the directory
mkdir /usr/local/nagios/etc/servers

#add configuration file for server to directory
cp /tmp/NTI-320/config_files/nagios/test-1-nti320.cfg /usr/local/nagios/etc/servers/test-1-nti320.cfg

#perform config check
/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

#restart services
systemctl restart nagios
systemctl restart httpd

#login to the nagios web interface at http://<your.nagios.server.ip>/nagios; u/n: nagiosadmin and password created earlier


#add local timezone support
#vim nagios.cfg   ----> #timezone offset ----> add line: use_timezone=US/Pacific
#vim /etc/httpd/conf.d/nagios.conf ---->will change timezone in CGI ---->add line: SetEnv TZ "US/Pacific" under <options execCGI>
#systemctl restart nagios
#systemctl restart httpd
#reload web interface for correct timezone
