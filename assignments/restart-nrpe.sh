#!/bin/bash

for i in $( gcloud compute instances list --zones us-west1-a | awk '{print $1}' | grep -v "NAME" );\
do gcloud compute ssh --zone us-west1-a Jonathan@$i --command "sudo systemctl restart nrpe";\
done;
