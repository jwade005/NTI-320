#!/bin/bash

# centos 7 rpm build server install script

# Install the RPM-Build package and the macros and helper scripts package:
sudo yum -y install rpm-build
sudo yum -y install redhat-rpm-config

# To create the RPM building environment, run the two commands below:
mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros

# Install extra packages with some useful tools and stuff:
sudo yum -y install make
sudo yum -y install yum-utils # This Package includes utilities that make yum easier and more powerful to use!

# Edit the following file to enable the centos source repos
#sudo vim /etc/yum.repos.d/CentOS-Sources.repo and enable the repos for access to source packages

sudo sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/CentosOS-Sources.repo


#adds support for nagios monitoring

echo "Cloning jwade005's github..."
yum -y install git
git clone https://github.com/jwade005/NTI-320.git

chmod +x /home/Jonathan/NTI-320/automation_scripts/nagios-remote-install.sh
chmod +x /home/Jonathan/NTI-320/automation_scripts/generate_config.sh

./home/Jonathan/NTI-320/automation_scripts/nagios-remote-install.sh

myusername="Jonathan"                         # set this to your username
mynagiosserver="nagios-a"                     # set this to your nagios server name
mycactiserver="cacti-a"                      # set this to your cacti server
myreposerver="yumrepo-a"                       # set this to your repo server
mynagiosserverip="35.197.81.237"                   # set this to the ip address of your nagios server

./home/Jonathan/NTI-320/automation_scripts/generate_config.sh rpmbuild-server 10.138.0.5              # code I gave you in a previous assignment that generates a nagios config

gcloud compute scp $1.cfg $myusername@$mynagiosserver:/etc/nagios/conf.d --zone us-west1-a

# gcloud compute scp /home/Jonathan/cacti-a2.cfg Jonathan@nagios-a:/etc/nagios/conf.d --zone us-west1-a

                                      # note: I had to add user my gcloud user to group nagios using usermod -a -G nagios $myusername on my nagios server in order to make this work.
                                      # I also had to chmod 770 /etc/nagios/conf.d


gcloud compute ssh $myusername@$mynagiosserver \
"sudo /usr/sbin/nagios -v /etc/nagios/nagios.cfg" \
| grep "Things look okay - No serious problems" \


if [[ $configstatus ]]; then
   gcloud compute ssh $myusername@$mynagiosserver --command "sudo systemctl restart nagios" --zone us-west1-a
   echo "$1 has been added to nagios."
else
   echo "There was a problem with the nagios config, please log into $mynagiosserver and run /usr/sbin/nagios -v /etc/nagios/nagios.cfg to figure out where the problem is";
   exit 1;
fi
