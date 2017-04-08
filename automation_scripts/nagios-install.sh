#!/bin/bash

#nagios core server install from source
#***** run as root *****

yum install -y wget httpd php gcc glibc glibc-common gd gd-devel make net-snmp unzip

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
/usr/sbin/nagios -v /etc/nagios/nagios.cfg

#login to the nagios web interface at http://<your.nagios.server.ip>/nagios; u/n: nagiosadmin and password created earlier


#add local timezone support
#vim nagios.cfg   ----> #timezone offste ----> add line: use_timezone=US/Pacific
#vim /etc/httpd/conf.d/nagios.conf ---->will change timezone in CGI ---->add line: SetEnv TZ "US/Pacific" under <options execCGI>
#systemctl restart nagios
#systemctl restart httpd
#reload web interface for correct timezone
