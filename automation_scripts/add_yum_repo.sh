#!/bin/bash

# this is a script to add a yum repo on a given server.


ip=$(gcloud compute instances list | grep postgres-c-production | awk '{print $4}') # will dynamically add ip address
echo "[jwade005repo]

name=jwade005repo NTI-320 - $basearch

baseurl=http://$ip/7/OS/x86_64/Packages/

enabled=1

gpgcheck=0

" >> /etc/yum.repos.d/NTI-320.repo
                                                                    # Now that the repo is added, list all repos and make sure
                                                                    # it shows up without error
yum repolist

isokay=`yum search "hello world" | grep "Matched: hello world"`

if [ -z "$isokay" ]; then
   echo "There's somthing wrong with your repo... check yum repolist to see if it shows up then try installing a package"
else
   echo "All is well and we found your test package: $isokay"
fi
