#!/bin/bash

# wrapper script for generate_config.sh

#ip=$(gcloud compute instances list | grep yumrepo-a | awk '{print $5}') # will dynamically add ip address

gcloud compute instances list | grep -v NAME | awk '{print $1}' # prints a list of instance NAMES

gcloud compute instances list | grep -v EXTERNAL_IP | awk '{print $5}' # prints a list of EXTERNAL_IPs
