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
    gcloud compute instances list --zones=$ZONE --format=json | jq -r '.[].name' | xargs -n 5 -r gcloud compute instances delete -q --zone=$ZONE
    gcloud compute disks list --zones=$ZONE --format=json | jq -r '.[].name' | xargs -n 5 -r gcloud compute disks delete -q --zone=$ZONE
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
    gcloud compute forwarding-rules list --regions=$REGION --format=json | jq -r '.[].name' | xargs -n 5 -r gcloud compute forwarding-rules delete -q --region=$REGION
done

gcloud compute target-http-proxies list --format=json | jq -r '.[].name' | xargs -n 5 -r gcloud compute target-http-proxies delete -q
gcloud compute target-https-proxies list --format=json | jq -r '.[].name' | xargs -n 5 -r gcloud compute target-https-proxies delete -q
gcloud compute target-ssl-proxies list --format=json | jq -r '.[].name' | xargs -n 5 -r gcloud compute target-ssl-proxies delete -q
gcloud compute url-maps list --format=json | jq -r '.[].name' | xargs -n 5 -r gcloud compute url-maps delete -q

gcloud compute backend-services list --global --format=json | jq -r '.[].name' | xargs -n 4 -r gcloud compute backend-services delete -q --global
for REGION in $REGIONS; do
    gcloud compute backend-services list --regions=$REGION --format=json | jq -r '.[].name' | xargs -n 4 -r gcloud compute backend-services delete -q --region=$REGION
done

for ZONE in $ZONES; do
    gcloud compute instance-groups list --zones=$ZONE --format=json | jq -r '.[].name' | xargs -n 2 -r gcloud compute instance-groups unmanaged delete -q --zone=$ZONE
done

gcloud compute firewall-rules list --format=json | jq -r '.[].name' | xargs -n 5 -r gcloud compute firewall-rules delete -q
gcloud compute networks subnets list --format=json | ./parse-subnets.py | xargs -I{} -n 1 -0 -r bash -c "gcloud compute networks subnets delete -q {}"
gcloud compute networks list --format=json | jq -r '.[] | select(.x_gcloud_mode == "custom") | .name' | xargs -n 5 -r gcloud compute networks delete -q

gcloud compute addresses list --global --format=json | jq -r '.[].name' | xargs -n 4 -r gcloud compute addresses delete -q --global
for REGION in $REGIONS; do
    gcloud compute addresses list --regions=$REGION --format=json | jq -r '.[].name' | xargs -n 4 -r gcloud compute addresses delete -q --region=$REGION
done

for REGION in $REGIONS; do
    gcloud compute target-pools list --regions=$REGION --format=json | jq -r '.[].name' | xargs -n 4 -r gcloud compute target-pools delete -q --region=$REGION
done

echo "Networking is gone"

echo "Cleaning up health checks..."
gcloud compute health-checks list --format=json | jq -r '.[].name' | xargs -n 5 -r gcloud compute health-checks delete -q
gcloud compute http-health-checks list --format=json | jq -r '.[].name' | xargs -n 5 -r gcloud compute http-health-checks delete -q
gcloud compute https-health-checks list --format=json | jq -r '.[].name' | xargs -n 5 -r gcloud compute https-health-checks delete -q
echo "Health Checks are gone"

# TODO: delete google SQL databases
# TODO: delete google storage buckets (gsutil wouldn't work with service credentials)
