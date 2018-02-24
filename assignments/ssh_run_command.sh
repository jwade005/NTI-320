for i in $( gcloud compute instances list | grep -v NAME | awk '{print $1}' );\
     do gcloud compute ssh --zone us-west1-a Jonathan@$i --command "<command to run on instance>";\
done;

