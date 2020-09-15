#!/bin/bash

## this command create the GCP compute instance (Linux VM) that runs everything for this hands-on
## upon creation, the vm is launching a script that install almost everything (keptn-in-a-box)
## and also clone the repo on the machine

## How this works (explained in the deck - slide 18)
## You need to provide 2 parameters
## $1 : <name of your GCP project> 
## $2 : <name of your GCP compute instance>

gcloud beta compute --project=$1 instances create $2 --zone=us-central1-a --machine-type=n2-standard-4 --subnet=default --network-tier=PREMIUM --maintenance-policy=MIGRATE --scopes=https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/devstorage.read_only --tags=http-server,https-server --image=ubuntu-1804-bionic-v20200821a --image-project=ubuntu-os-cloud --boot-disk-size=20GB --boot-disk-type=pd-standard --boot-disk-device-name=sc-test --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --labels=owner=stevecaron,purpose=bootcampqg --reservation-affinity=any --metadata startup-script-url=https://raw.githubusercontent.com/steve-caron-dynatrace/se-bootcamp-keptn-qg/master/0-Setup/keptn-in-a-box.sh