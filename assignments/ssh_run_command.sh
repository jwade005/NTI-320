for i in $( gcloud compute instances list | grep -v NAME | awk '{print $1}' );
    do gcloud compute ssh Jonathan@$i " ";
done

