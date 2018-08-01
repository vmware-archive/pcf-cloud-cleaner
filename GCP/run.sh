#!/bin/bash
set -e

# login, requires a service account & JSON config
gcloud auth activate-service-account \
    "$GCP_ACCOUNT" \
    --key-file "$GCP_SERVICE_FILE"

export CLOUDSDK_CORE_PROJECT="$GCP_PROJECT"

echo "Deleting Instances..."
ZONES=$(gcloud compute zones list --format=json | jq -r '.[].name')
for ZONE in $ZONES; do
    echo "Cleaning Zone [$ZONE]"
    gcloud compute instances list --filter="zone:($ZONE)" --format=json | jq -r '.[].name' | xargs -n 5 -r gcloud compute instances delete -q --zone=$ZONE
    gcloud compute disks list --filter="zone:($ZONE)" --format=json | jq -r '.[].name' | xargs -n 5 -r gcloud compute disks delete -q --zone=$ZONE
done
echo "Instances gone"

echo "Deleting custom images..."
gcloud compute images list --no-standard-images --format=json | jq -r '.[].name' | xargs -n 5 -r gcloud compute images delete -q
echo "Custom images gone"

# clean up networking
echo "Cleaning up networking..."
REGIONS=$(gcloud compute regions list --format=json | jq -r '.[].name')

gcloud compute forwarding-rules list --global --format=json | jq -r '.[].name' | xargs -n 5 -r gcloud compute forwarding-rules delete -q --global
for REGION in $REGIONS; do
    gcloud compute forwarding-rules list --filter="region:($REGION)" --format=json | jq -r '.[].name' | xargs -n 5 -r gcloud compute forwarding-rules delete -q --region=$REGION
done

gcloud compute target-http-proxies list --format=json | jq -r '.[].name' | xargs -n 5 -r gcloud compute target-http-proxies delete -q
gcloud compute target-https-proxies list --format=json | jq -r '.[].name' | xargs -n 5 -r gcloud compute target-https-proxies delete -q
gcloud compute target-ssl-proxies list --format=json | jq -r '.[].name' | xargs -n 5 -r gcloud compute target-ssl-proxies delete -q
gcloud compute url-maps list --format=json | jq -r '.[].name' | xargs -n 5 -r gcloud compute url-maps delete -q

gcloud compute backend-services list --global --format=json | jq -r '.[].name' | xargs -n 4 -r gcloud compute backend-services delete -q --global
for REGION in $REGIONS; do
    gcloud compute backend-services list --filter="region:($REGION)" --format=json | jq -r '.[].name' | xargs -n 4 -r gcloud compute backend-services delete -q --region=$REGION
done

for ZONE in $ZONES; do
    gcloud compute instance-groups list --filter="zone:($ZONE)" --format=json | jq -r '.[].name' | xargs -n 2 -r gcloud compute instance-groups unmanaged delete -q --zone=$ZONE
done

gcloud compute firewall-rules list --format=json | jq -r '.[].name' | xargs -n 5 -r gcloud compute firewall-rules delete -q
# delete non-default routes
gcloud compute routes list --format=json | jq -r ' .[] | select( .name | startswith("default-") | not) | .name' | xargs -n 5 -r gcloud compute routes delete -q
# delete auto subnet networks first, because we can't delete those subnets
gcloud compute networks list --format=json | jq -r '.[] | select(.x_gcloud_subnet_mode == "AUTO") | .name' | xargs -n 5 -r gcloud compute networks delete -q
# delete subnets for custom networks
gcloud compute networks subnets list --format=json | ./parse-subnets.py | xargs -I{} -n 1 -0 -r bash -c "gcloud compute networks subnets delete -q {}"
# delete custom networks
gcloud compute networks list --format=json | jq -r '.[] | select(.x_gcloud_subnet_mode == "CUSTOM") | .name' | xargs -n 5 -r gcloud compute networks delete -q

gcloud compute addresses list --global --format=json | jq -r '.[].name' | xargs -n 4 -r gcloud compute addresses delete -q --global
for REGION in $REGIONS; do
    gcloud compute addresses list --filter="region:($REGION)" --format=json | jq -r '.[].name' | xargs -n 4 -r gcloud compute addresses delete -q --region=$REGION
done

for REGION in $REGIONS; do
    gcloud compute target-pools list --filter="region:($REGION)" --format=json | jq -r '.[].name' | xargs -n 4 -r gcloud compute target-pools delete -q --region=$REGION
done

echo "Networking is gone"

echo "Cleaning up health checks..."
gcloud compute health-checks list --format=json | jq -r '.[].name' | xargs -n 5 -r gcloud compute health-checks delete -q
gcloud compute http-health-checks list --format=json | jq -r '.[].name' | xargs -n 5 -r gcloud compute http-health-checks delete -q
gcloud compute https-health-checks list --format=json | jq -r '.[].name' | xargs -n 5 -r gcloud compute https-health-checks delete -q
echo "Health Checks are gone"

echo "Cleaning up Google SQL database..."
gcloud sql instances list --format=json | jq -r '.[].name' | xargs -n 1 -r gcloud sql instances delete
echo "Google SQL databases gone."

# TODO: delete google storage buckets (gsutil wouldn't work with service credentials)
