#!/bin/bash

chmod +x /home/Jonathan/NTI-320/automation_scripts/nagios-remote-install-yum.sh
chmod +x /home/Jonathan/NTI-320/automation_scripts/generate_config.sh

/home/Jonathan/NTI-320/automation_scripts/nagios-remote-install-yum.sh

myusername="Jonathan"                         # set this to your username
mynagiosserver="nagios-a"                     # set this to your nagios server name
mycactiserver="cacti-a2"                      # set this to your cacti server
myreposerver="yumrepo-a"                       # set this to your repo server
mynagiosserverip="35.197.81.237"                   # set this to the ip address of your nagios server


/home/Jonathan/NTI-320/automation_scripts/generate_config.sh cacti-a2 10.138.0.2              # code I gave you in a previous assignment that generates a nagios config

gcloud compute scp $1.cfg $myusername@$mynagiosserver:/etc/nagios/conf.d

                                      # note: I had to add user my gcloud user to group nagios using usermod -a -G nagios $myusername on my nagios server in order to make this work.
                                      # I also had to chmod 770 /etc/nagios/conf.d


gcloud compute ssh $myusername@$mynagiosserver \
--command="sudo /usr/sbin/nagios -v /etc/nagios/nagios.cfg" \
| grep "Things look okay - No serious problems" \

if [[ $configstatus ]]; then
   gcloud compute ssh $myusername@$mynagiosserver --command="sudo systemctl restart nagios" --ssh-key-file=/home/Jonathan/google_compute_engine
   echo "$1 has been added to nagios."
else
   echo "There was a problem with the nagios config, please log into $mynagiosserver and run /usr/sbin/nagios -v /etc/nagios/nagios.cfg to figure out where the problem is";
   exit 1;
fi
