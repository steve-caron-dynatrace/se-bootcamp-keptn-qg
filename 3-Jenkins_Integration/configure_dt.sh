#!/bin/bash

source ../utils/utils.sh

readCredsFromFile

source ../utils/createTestRequestAttributes.sh
source ../utils/createCalculatedMetrics.sh $1 $2
source ../utils/createTestStepCalculatedMetrics.sh $1 $2
source ../utils/createLoadTestingDashboard.sh ""
