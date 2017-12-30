for i in $( gcloud compute instances list | awk '{print $1}' );
    do gcloud compute ssh Jonathan@$i " ";
done

