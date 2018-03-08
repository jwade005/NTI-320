#!/bin/bash

# instance spin up and startup script code

echo "This is jwade005's NTI-320 GCloud Automation"

echo "Authorizing jwade005 for this project..."
gcloud auth login wadejonathan005@gmail.com --no-launch-browser

echo "Enabling billing..."
gcloud alpha billing accounts projects link final-test-project-2 --account-id=00CB7D-C97746-2D8BC1

echo "Setting admin account-id..."
gcloud config set account wadejonathan005@gmail.com

echo "Setting the project for Configuration..."
gcloud config set project final-test-project-2

echo "Setting zone/region for Configuration..."
gcloud config set compute/zone us-west1-a

gcloud config set compute/region us-west1

echo "Creating firewall-rules..."
gcloud compute firewall-rules create allow-http --description "Incoming http allowed." \
    --allow tcp:80

gcloud compute firewall-rules create allow-nrpe --description "Allow nrpe-server communication." \
    --allow tcp:5666

gcloud compute firewall-rules create allow-ldap --description "Incoming ldap allowed." \
    --allow tcp:636

gcloud compute firewall-rules create allow-postgresql --description "Posgresql allowed." \
    --allow tcp:5432

gcloud compute firewall-rules create allow-https --description "Incoming https allowed." \
    --allow tcp:443

gcloud compute firewall-rules create allow-django --description "Django test server connection allowed." \
    --allow tcp:8000

gcloud compute firewall-rules create allow-ftp --description "FTP Allowed." \
    --allow tcp:21


echo "Creating the rpmbuild-server instance and running the install script..."
gcloud compute instances create rpmbuild-server \
    --image-family centos-7 \
    --image-project centos-cloud \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --metadata-from-file startup-script=/Users/Jonathan/Desktop/NET320/NTI-320/automation_scripts/rpm-install-centos7.sh \

echo "Creating the rsyslog-server instance and running the install script..."
gcloud compute instances create rsyslog-server \
    --image-family centos-7 \
    --image-project centos-cloud \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --metadata-from-file startup-script=/Users/Jonathan/Desktop/NET320/NTI-320/automation_scripts/rsyslog-server.sh \

echo "Creating the ldap-server instance and running the install script..."
gcloud compute instances create ldap-server \
    --image-family centos-7 \
    --image-project centos-cloud \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --metadata-from-file startup-script=/Users/Jonathan/Desktop/NET320/NTI-320/automation_scripts/ldap-server-install.sh \

echo "Creating the nfs-server and running the install script..."
gcloud compute instances create nfs-server \
    --image-family centos-7 \
    --image-project centos-cloud \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --metadata-from-file startup-script=/Users/Jonathan/Desktop/NET320/NTI-320/automation_scripts/nfs-server-install.sh \

echo "Creating the postgres-a-test server and running the install script..."
gcloud compute instances create postgres-a-test \
    --image-family centos-7 \
    --image-project centos-cloud \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --metadata-from-file startup-script=/Users/Jonathan/Desktop/NET320/NTI-320/automation_scripts/postgres-a-test-server.sh \

echo "Creating the django-a-test server and running the install script..."
gcloud compute instances create django-a-test \
    --image-family centos-7 \
    --image-project centos-cloud \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --metadata-from-file startup-script=/Users/Jonathan/Desktop/NET320/NTI-320/automation_scripts/apache-django-install.sh \

echo "Sleeping for a bit to let the startup scripts do their things. :)"

sleep 120

# add script to add nrpe to each isntance (nagios-remote-istall-yum.sh) DONE

# add wrapper script addon to startup scripts to create nagios config files for each instances (using genconfig_wrapper.sh) DONE

# add scp commands to send nagios config files to the nagios server and test configuration (using gcloud_scp_nagios.sh) DONE


# NAGIOS SUPPORT


# rpmbuild-server

#adds support for nagios monitoring

echo "Creating cfg file for the rpmbuild-server and uploading it to nagios-a."

myusername="Jonathan"                         # set this to your username
mynagiosserver="nagios-a"                     # set this to your nagios server name
mycactiserver="cacti-a"                      # set this to your cacti server
myreposerver="yumrepo-a"                       # set this to your repo server
mynagiosserverip="35.227.159.216"                   # set this to the ip address of your nagios server

ip1=$(gcloud compute instances list | grep rpmbuild-server | awk '{print $4}')

./generate_config.sh rpmbuild-server $ip1              # code I gave you in a previous assignment that generates a nagios config

gcloud compute scp rpmbuild-server.cfg $myusername@$mynagiosserver:/etc/nagios/conf.d --zone us-west1-a

#gcloud compute ssh $myusername@$mynagiosserver \
#--command "sudo /usr/sbin/nagios -v /etc/nagios/nagios.cfg" \
#| grep "Things look okay - No serious problems" \


#if [[ $configstatus ]]; then
#   gcloud compute ssh $myusername@$mynagiosserver --command "sudo systemctl restart nagios" --zone us-west1-a
#   echo "$1 has been added to nagios."
#else
#   echo "There was a problem with the nagios config, please log into $mynagiosserver and run /usr/sbin/nagios -v /etc/nagios/nagios.cfg to figure out where the problem is";
#   exit 1;
#fi


#rsyslog-server

echo "Creating cfg file for the rsyslog-server and uploading it to nagios-a."

myusername="Jonathan"                         # set this to your username
mynagiosserver="nagios-a"                     # set this to your nagios server name
mycactiserver="cacti-a"                      # set this to your cacti server
myreposerver="yumrepo-a"                       # set this to your repo server
mynagiosserverip="35.227.159.216"                   # set this to the ip address of your nagios server

ip2=$(gcloud compute instances list | grep rsyslog-server | awk '{print $4}')

./generate_config.sh rsyslog-server $ip2              # code I gave you in a previous assignment that generates a nagios config

gcloud compute scp rsyslog-server.cfg $myusername@$mynagiosserver:/etc/nagios/conf.d --zone us-west1-a

#gcloud compute ssh $myusername@$mynagiosserver \
#--command "sudo /usr/sbin/nagios -v /etc/nagios/nagios.cfg" \
#| grep "Things look okay - No serious problems" \


#if [[ $configstatus ]]; then
#   gcloud compute ssh $myusername@$mynagiosserver "sudo systemctl restart nagios"
#   echo "$1 has been added to nagios."
#else
#   echo "There was a problem with the nagios config, please log into $mynagiosserver and run /usr/sbin/nagios -v /etc/nagios/nagios.cfg to figure out where the problem is";
#   exit 1;
#fi


#ldap-server

echo "Creating cfg file for the ldap-server and uploading it to nagios-a."

myusername="Jonathan"                         # set this to your username
mynagiosserver="nagios-a"                     # set this to your nagios server name
mycactiserver="cacti-a"                      # set this to your cacti server
myreposerver="yumrepo-a"                       # set this to your repo server
mynagiosserverip="35.227.159.216"                   # set this to the ip address of your nagios server

ip3=$(gcloud compute instances list | grep ldap-server | awk '{print $4}')

./generate_config.sh ldap-server $ip3             # code I gave you in a previous assignment that generates a nagios config

gcloud compute scp ldap-server.cfg $myusername@$mynagiosserver:/etc/nagios/conf.d --zone us-west1-a

#gcloud compute ssh $myusername@$mynagiosserver \
#--command "sudo /usr/sbin/nagios -v /etc/nagios/nagios.cfg" \
#| grep "Things look okay - No serious problems" \


#if [[ $configstatus ]]; then
#   gcloud compute ssh $myusername@$mynagiosserver --command "sudo systemctl restart nagios" --zone us-west1-a
#   echo "$1 has been added to nagios."
#else
#   echo "There was a problem with the nagios config, please log into $mynagiosserver and run /usr/sbin/nagios -v /etc/nagios/nagios.cfg to figure out where the problem is";
#   exit 1;
#fi


#nfs-server

echo "Creating cfg file for the nfs-server and uploading it to nagios-a."

myusername="Jonathan"                         # set this to your username
mynagiosserver="nagios-a"                     # set this to your nagios server name
mycactiserver="cacti-a"                      # set this to your cacti server
myreposerver="yumrepo-a"                       # set this to your repo server
mynagiosserverip="35.227.159.216"                   # set this to the ip address of your nagios server

ip4=$(gcloud compute instances list | grep nfs-server | awk '{print $4}')

./generate_config.sh nfs-server $ip4              # code I gave you in a previous assignment that generates a nagios config

gcloud compute scp nfs-server.cfg $myusername@$mynagiosserver:/etc/nagios/conf.d --zone us-west1-a

#name@$mynagiosserver \
#--command "sudo /usr/sbin/nagios -v /etc/nagios/nagios.cfg" \
#| grep "Things look okay - No serious problems" \


#if [[ $configstatus ]]; then
#   gcloud compute ssh $myusername@$mynagiosserver --command "sudo systemctl restart nagios" --zone us-west1-a
#   echo "$1 has been added to nagios."
#else
#   echo "There was a problem with the nagios config, please log into $mynagiosserver and run /usr/sbin/nagios -v /etc/nagios/nagios.cfg to figure out where the problem is";
#   exit 1;
#fi


#postgres-a-test

echo "Creating cfg file for the postgres-a-test-server and uploading it to nagios-a."

myusername="Jonathan"                         # set this to your username
mynagiosserver="nagios-a"                     # set this to your nagios server name
mycactiserver="cacti-a"                      # set this to your cacti server
myreposerver="yumrepo-a"                       # set this to your repo server
mynagiosserverip="35.227.159.216"                   # set this to the ip address of your nagios server

ip5=$(gcloud compute instances list | grep postgres-a-test | awk '{print $4}')

./generate_config.sh postgres-a-test $ip5              # code I gave you in a previous assignment that generates a nagios config

gcloud compute scp postgres-a-test.cfg $myusername@$mynagiosserver:/etc/nagios/conf.d --zone us-west1-a

#gcloud compute ssh $myusername@$mynagiosserver \
#--command "sudo /usr/sbin/nagios -v /etc/nagios/nagios.cfg" \
#| grep "Things look okay - No serious problems" \


#if [[ $configstatus ]]; then
#   gcloud compute ssh $myusername@$mynagiosserver --command "sudo systemctl restart nagios" --zone us-west1-a
#   echo "$1 has been added to nagios."
#else
#   echo "There was a problem with the nagios config, please log into $mynagiosserver and run /usr/sbin/nagios -v /etc/nagios/nagios.cfg to figure out where the problem is";
#   exit 1;
#fi


#django-a-test

echo "Creating cfg file for the django-a-test-server and uploading it to nagios-a."

myusername="Jonathan"                         # set this to your username
mynagiosserver="nagios-a"                     # set this to your nagios server name
mycactiserver="cacti-a"                      # set this to your cacti server
myreposerver="yumrepo-a"                       # set this to your repo server
mynagiosserverip="35.227.159.216"                   # set this to the ip address of your nagios server

ip6=$(gcloud compute instances list | grep django-a-test | awk '{print $4}')

./generate_config.sh django-a-test $ip6             # code I gave you in a previous assignment that generates a nagios config

gcloud compute scp django-a-test.cfg $myusername@$mynagiosserver:/etc/nagios/conf.d --zone us-west1-a

#gcloud compute ssh $myusername@$mynagiosserver \
#--command "sudo /usr/sbin/nagios -v /etc/nagios/nagios.cfg" \
#| grep "Things look okay - No serious problems" \


#if [[ $configstatus ]]; then
#   gcloud compute ssh $myusername@$mynagiosserver --command "sudo systemctl restart nagios" --zone us-west1-a
#   echo "$1 has been added to nagios."
#else
#   echo "There was a problem with the nagios config, please log into $mynagiosserver and run /usr/sbin/nagios -v /etc/nagios/nagios.cfg to figure out where the problem is";
#   exit 1;
#fi

echo "Restarting nagios service on the nagios-a server."

gcloud compute ssh Jonathan@nagios-a --command "sudo systemctl restart nagios"

# script adds yumrepo to all servers on gcloud network
# yumrepo added at the end of the gcloud startup script 

#echo "Adding jwade005's yum repo to all instances in the gcloud network."

#for i in $( gcloud compute instances list --zones us-west1-a | awk '{print $1}' | grep -v "NAME" );\
#do gcloud compute ssh --zone us-west1-a Jonathan@$i --command "./NTI-320/automation_scripts/add_yum_repo.sh";\
#done;

echo "Jwade005's Google Cloud NTI-320 Final Project Automatic Installation Complete. :)"
