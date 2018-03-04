#!/bin/bash

# wrapper script for generate_config.sh

#ip=$(gcloud compute instances list | grep yumrepo-a | awk '{print $5}') # will dynamically add ip address

1=$(gcloud compute instances list | grep -v test-vm-a | awk '{print $1}') # prints a list of instance NAMES

2=$(gcloud compute instances list | grep -v test-vm-a | awk '{print $5}') # prints a list of EXTERNAL_IPs

myusername="Jonathan"                           # username
mynagiosserver="nagios-a"                       # nagios server name
mycactiserver="cacti-a"                         # cacti server name
myreposerver="yumrepo-a"                        # repo server
mynagiosserverip="10.138.0.3"                # ip address of your nagios server

generate_config.sh $1 $2              # script to generate nagios config $1 >> hostname, $2 >> host IP address

#gcloud compute copy-files $1.cfg $myusername@$mynagiosserver:/etc/nagios/conf.d

                                      # note: add user Jonathan to group nagios using 'usermod -a -G nagios Jonathan' on nagios server
                                      # also chmod 770 /etc/nagios/conf.d


# command to scp cfg file from instance to local directory
gcloud compute scp test-vm-a:/home/Jonathan/test-vm-a.cfg /Users/Jonathan/ --ssh-key-file=/Users/Jonathan/.ssh/google_compute_engine --zone us-west1-a

# command to scp cfg file from local directory to nagios server
gcloud compute scp /Users/Jonathan/test-vm-a.cfg Jonathan@nagios-a:/etc/nagios/conf.d/ --ssh-key-file=/Users/Jonathan/.ssh/google_compute_engine --zone us-west1-a


#gcloud compute ssh $myusername@$mynagiosserver \
#"sudo /usr/sbin/nagios -v /etc/nagios/nagios.cfg" \
#| grep "Things look okay - No serious problems" \

gcloud compute ssh Jonathan@nagios-a --zone us-west1-a --command "sudo /usr/sbin/nagios -v /etc/nagios/nagios.cfg" | grep "Things look okay - No serious problems"

if [[ $configstatus ]]; then
   gcloud compute ssh $myusername@$mynagiosserver "sudo systemctl restart nagios"
   echo "$1 has been added to nagios."
else
   echo "There was a problem with the nagios config, please log into $mynagiosserver and run /usr/sbin/nagios -v /etc/nagios/nagios.cfg to figure out where the problem is";
   exit 1;
fi
