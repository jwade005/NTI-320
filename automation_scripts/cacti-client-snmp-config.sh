#!/bin/bash

# client-side snmp configuration for cacti monitoring
# ***** run as root *****

# install snmp and tools
yum -y install net-snmp net-snmp-utils


# copy snmp file and create a new one
mv /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.orig
touch /etc/snmp/snmpd.conf


# edit snmpd.conf file /etc/snmp/snmpd.conf
#vim /etc/snmp/snmpd.conf
echo "# A user 'myUser' is being defined with the community string 'myCommunity' and source network 10.138.0.0/24
com2sec myUser 10.138.0.0/24 myCommunity

# myUser is added into the group 'myGroup' and the permission of the group is defined
group    myGroup    v1        myUser
group    myGroup    v2c        myUser
view all included .1
access myGroup    ""    any    noauth     exact    all    all    none" >> /etc/snmp/snmpd.conf


# enable and start snmp service
systemctl enable snmpd
systemctl start snmpd

# make snmp survive a reboot
chkconfig snmpd on

# test config with client ip - success will generate a lot of output
#snmpwalk -c myCommunity <client.ip address> -v2c
