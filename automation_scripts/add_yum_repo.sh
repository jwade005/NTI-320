    #!/bin/bash

    # adds yum repo on a server


    ip=$(gcloud compute instances list | grep yumrepo-a | awk '{print $4}') # will dynamically add ip address
    echo "[jwade005repo]

    name=jwade005repo NTI-320 - $basearch

    baseurl=http://$ip/CentOS/7/OS/x86_64/Packages/

    enabled=1

    gpgcheck=0

    " >> /etc/yum.repos.d/NTI-320.repo
                                                                        # Now that the repo is added, list all repos and make sure
                                                                        # it shows up without error
    yum repolist

    isokay=`yum search "jwade005repo NTI-320" | grep "jwade005repo NTI-320"`

    if [ -z "$isokay" ]; then
       echo "There's somthing wrong with your repo... check yum repolist to see if it shows up then try installing a package"
    else
       echo "All is well and we found your test package: $isokay"
    fi
