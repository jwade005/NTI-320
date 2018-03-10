#!/bin/bash

for i in $( gcloud compute instances list --zones us-west1-a | awk '{print $1}' | grep -v "NAME" );\
do gcloud compute ssh --zone us-west1-a Jonathan@$i --command "sudo sed -i 's,baseurl=http:\/\/10.138.0.4\/7\/OS\/x86_64\/Packages\/,baseurl=http:\/\/35.197.67.252\/CentOS\/7\/x86_64/Packages\/,g' /etc/yum.repos.d/NTI-320.repo && sudo yum -y install nti-320-plugins-0.1";\
done;
