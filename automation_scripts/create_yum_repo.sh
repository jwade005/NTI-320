#!/bin/bash

#creates a yum repo and copies packages to repo directory
# *****run as root*****

yum -y install createrepo
mkdir -p /repos/CentOS/7/x86_64/Packages/

gcloud compute scp ~/Desktop/net320/check_jwade005_plugin-1.0-1.el7.centos.x86_64.rpm \yumrepo-a:/home/Jonathan/ --ssh-key-file=/Users/Jonathan/.ssh/google_compute_engine --zone us-west1-a

mv check_jwade005_plugin-1.0-1.el7.centos.x86_64.rpm /repos/CentOS/7/x86_64/Packages/

yum -y install httpd

setenforce 0

createrepo /repos/CentOS/7/x86_64/Packages/

systemctl enable httpd

systemctl start httpd

ln -s /repos/CentOS /var/www/html/CentOS

cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bak

sed -i '144i     Options All' /etc/httpd/conf/httpd.conf                          # Configure apache
sed -i '145i    # Disable directory index so that it will index our repos' /etc/httpd/conf/httpd.conf
sed -i '146i     DirectoryIndex disabled' /etc/httpd/conf/httpd.conf

sed -i 's/^/#/' /etc/httpd/conf.d/welcome.conf

chown -R apache:apache /repos/

systemctl restart httpd
