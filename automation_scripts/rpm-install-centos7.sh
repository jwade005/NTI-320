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


# support for nagios monitoring

echo "Cloning jwade005's github..."
yum -y install git
git clone https://github.com/jwade005/NTI-320.git

chmod +x /home/Jonathan/NTI-320/automation_scripts/nagios-remote-install-yum.sh
/home/Jonathan/NTI-320/automation_scripts/nagios-remote-install-yum.sh
