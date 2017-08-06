#!/bin/bash

# scp nagios cfg files to nagios server

/Users/Jonathan/Desktop/NET320/NTI-320/automation_scripts/generate_config.sh $1 $2

gcloud compute scp ~/$1.cfg \nagios-a:/etc/nagios/conf.d --ssh-key-file=/Users/Jonathan/.ssh/google_compute_engine --zone us-west1-a

# add user Jonathan to group nagios using: usermod -a -G nagios Jonathan
# chmod 770 /etc/nagios/conf.d

gcloud compute ssh Jonathan@nagios-a "sudo /usr/sbin/nagios -v /etc/nagios/nagios.cfg"
