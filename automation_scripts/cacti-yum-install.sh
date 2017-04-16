#!/bin/bash

# install cacti
yum -y install cacti

# install mariadb server, an opensourse db server from the developers of mysql
yum -y install mariadb-server

# install components
yum -y install php-process php-gd

# Enable db, apache and snmp services
systemctl enable mariadb
systemctl enable httpd
systemctl enable snmpd

# Start db, apache and snmp services
systemctl start mariadb
systemctl start httpd
systemctl start snmpd

# turn off SE linux
setenforce 0

# set database password
mysqladmin -u root password P@ssw0rd1

# use local timezone with database
mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root -pP@ssw0rd1 mysql    # ******* add password support for automation

# create slq script
echo "create database cacti;
GRANT ALL ON cacti.* TO cacti@localhost IDENTIFIED BY 'P@ssw0rd1';
FLUSH privileges;

GRANT SELECT ON mysql.time_zone_name TO cacti@localhost;
flush privileges;" > stuff.sql

# run sql script
mysql -u root  -pP@ssw0rd1 < stuff.sql                                       # ******* add password support for automation

rpm -ql cacti|grep cacti.sql     # Will list the location of the package cacti sql script

# run the cacti sql script
mysql -u cacti -pP@ssw0rd1 cacti < /usr/share/doc/cacti-1.0.4/cacti.sql      # ******* add password support for automation

# create sed lines to modify access   ******
# vim /etc/httpd/conf.d/cacti.conf
sed -i 's/Require host localhost/Require host 10.138.0.0\/24/,g' /etc/httpd/conf.d/cacti.conf
sed -i 's/Allow from localhost/Allow from 10.138.0.0\/24/,g' /etc/httpd/conf.d/cacti.conf

# create sed lines to change username and password for cacti
#vim /etc/cacti/db.php
sed -i 's/$database_username = "cactiuser";/$database_username = "cacti";/,g' /etc/cacti/db/php
sed -i 's/$database_password = "cactipass";/$database_password = "P@ssw0rd1";/,g' /etc/cacti/db/php

# restart httpd service
systemctl restart httpd.service

# uncomment cronjob for cacti to poll every 5 minutes
sed -i 's/#//g' /etc/cron.d/cacti

# add sed lines for timezone support    /etc/php.ini      *******
cp /etc/php.ini /etc/php.ini.orig
sed -i 's/#date.timezone = /date.timezone = America\/Regina/,g' /etc/php.ini
