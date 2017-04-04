#!/bin/bash

#nagios core server install from source
#***** run as root *****

yum install -y wget httpd php gcc glibc glibc-common gd gd-devel make net-snmp unzip

cd /tmp

#this will download Nagios Core and plugins

wget http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-4.2.0.tar.gz
wget http://nagios-plugins.org/download/nagios-plugins-2.1.2.tar.gz

#add users and groups for nagios processes

useradd nagios
groupadd nagcmd
usermod -a -G nagcmd nagios
usermod -a -G nagios,nagcmd apache

#extract packages

tar zxvf nagios-4.2.0.tar.gz
tar zxvf nagios-plugins-2.1.2.tar.gz

#cd to nagios directory and install the packages
cd nagios-4.2.0

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

htpasswd –c /usr/local/nagios/etc/htpasswd.users nagiosadmin

#install nagios plugins

cd /tmp/nagios-plugins-2.1.2
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make
make install

#the following commands will register the Nagios daemon to be run upon system startup
chkconfig --add nagios
chkconfig --level 35 nagios on
chkconfig --add httpd
chkconfig --level 35 httpd on

#login to the nagios web interface at http://<your.nagios.server.ip>/nagios; u/n: nagiosadmin and password created earlier


