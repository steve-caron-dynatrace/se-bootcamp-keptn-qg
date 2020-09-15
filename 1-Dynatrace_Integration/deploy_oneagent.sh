#!/bin/bash

source ../utils/utils.sh

readCredsFromFile

wget -O Dynatrace-OneAgent-Linux.sh "https://$DT_TENANT/api/v1/deployment/installer/agent/unix/default/latest?arch=x86&flavor=default" --header="Authorization: Api-Token $DT_PAAS_TOKEN"

sudo /bin/sh Dynatrace-OneAgent-Linux.sh --set-app-log-content-access=true --set-infra-only=false 

rm Dynatrace-OneAgent-Linux.sh

# restarting our app containers
docker restart simplenodeservice
docker restart simplenodeservice-jenkins
