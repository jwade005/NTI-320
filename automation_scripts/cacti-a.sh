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
mysql -u cacti -pP@ssw0rd1 cacti < /usr/share/doc/cacti-1.1.7/cacti.sql      # ******* add password support for automation

# create sed lines to modify access   ******
# vim /etc/httpd/conf.d/cacti.conf
sed -i 's/Require host localhost/Require all granted/' /etc/httpd/conf.d/cacti.conf
sed -i 's/Allow from localhost/Allow from all all/' /etc/httpd/conf.d/cacti.conf

# create sed lines to change username and password for cacti
#vim /etc/cacti/db.php
sed -i "s/\$database_username = 'cactiuser';/\$database_username = 'cacti';/" /etc/cacti/db.php
sed -i "s/\$database_password = 'cactipass';/\$database_password = 'P@ssw0rd1';/" /etc/cacti/db.php

# restart httpd service
systemctl restart httpd.service

# uncomment cronjob for cacti to poll every 5 minutes
sed -i 's/#//g' /etc/cron.d/cacti

# add sed lines for timezone support    /etc/php.ini      *******
cp /etc/php.ini /etc/php.ini.orig
sed -i 's/;date.timezone =/date.timezone = America\/Regina/' /etc/php.ini

echo "Cloning jwade005's NTI-310 GitHub..."
sudo yum -y install git
sudo git clone https://github.com/jwade005/NTI-320.git /tmp/NTI-320
sudo git config --global user.name "jwade005"
sudo git config --global user.email "jwade005@seattlecentral.edu"

myusername="jwade005"                         # set this to your username
mynagiosserver="nagios-a"                     # set this to your nagios server name
mycactiserver="cacti-a"                      # set this to your cacti server
myreposerver="yum-repo"                       # set this to your repo server
mynagiosserverip="35.185.217.151"                   # set this to the ip address of your nagios server

./tmp/NTI-320/automation_scripts/generate_config.sh $1 $2              # code I gave you in a previous assignment that generates a nagios config

gcloud compute copy-files $1.cfg $myusername@$mynagiosserver:/etc/nagios/conf.d

                                      # note: I had to add user my gcloud user to group nagios using usermod -a -G nagios $myusername on my nagios server in order to make this work.
                                      # I also had to chmod 770 /etc/nagios/conf.d

configstatus=$( \
gcloud compute ssh $myusername@$mynagiosserver \
"sudo /usr/sbin/nagios -v /etc/nagios/nagios.cfg" \
| grep "Things look okay - No serious problems" \
)

if [[ $configstatus ]]; then
   gcloud compute ssh $myusername@$mynagiosserver "sudo systemctl restart nagios"
   echo "$1 has been added to nagios."
else
   echo "There was a problem with the nagios config, please log into $mynagiosserver and run /usr/sbin/nagios -v /etc/nagios/nagios.cfg to figure out where the problem is";
   exit 1;
fi
