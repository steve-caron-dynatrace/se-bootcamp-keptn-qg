#!/bin/bash

if [ -z "$1" ]
then
  echo "No argument supplied. Please provide the simple node app URL as an argument."
else
  # removing potential trailing slash	
  URL=$(echo "$1" | sed 's/\/*$//g')

  echo 'Gate run #1'
  for i in {1..20} 
  do
    curl --silent --output nul --show-error $URL'/api/echo?text=Just%20say%20whatever%20you%20want&sleep=500' 
  done

  sleep 60s

  keptn send event start-evaluation --project=standalone-qg --stage=qualitystage --service=simplenodeservice --timeframe=2m --labels=gaterun=1,type=viacli

  sleep 60s

  echo 'Gate run #2'
  for i in {1..20}
  do
    curl --silent --output nul --show-error $URL'/api/echo?text=Just%20say%20whatever%20you%20want&sleep=800'
  done

  sleep 60s

  keptn send event start-evaluation --project=standalone-qg --stage=qualitystage --service=simplenodeservice --timeframe=2m --labels=gaterun=2,type=viacli

  sleep 60s

  echo 'Gate run #3'
  for i in {1..20}
  do
    curl --silent --output nul --show-error $URL'/api/echo?text=Just%20say%20whatever%20you%20want&sleep=600'
  done

  for i in {1..5}
  do
    curl --silent --output nul --show-error $URL'/api/invoke?url=https://www.dynatrace.com&sleep=1000'
  done

  sleep 60s

  keptn send event start-evaluation --project=standalone-qg --stage=qualitystage --service=simplenodeservice --timeframe=2m --labels=gaterun=3,type=viacli

  echo DONE!
fi
