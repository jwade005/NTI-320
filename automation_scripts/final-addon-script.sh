myusername="jwade005"                         # set this to your username
mynagiosserver="nagios-a"                     # set this to your nagios server name
mycactiserver="cacti-a"                      # set this to your cacti server
myreposerver="yum-repo"                       # set this to your repo server
mynagiosserverip="35.185.217.151"                   # set this to the ip address of your nagios server

generate_config.sh $1 $2              # code I gave you in a previous assignment that generates a nagios config

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
