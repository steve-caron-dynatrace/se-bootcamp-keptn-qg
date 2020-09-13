#!/bin/bash

echo 'Gate run #1'
for i in {1..20} 
do
  curl --silent --output nul --show-error 'http://35-192-62-255.nip.io:8070/api/echo?text=Just%20say%20whatever%20you%20want&sleep=500' 
done

sleep 60s

keptn send event start-evaluation --project=standalone-qg --stage=qualitystage --service=simplenodeservice --timeframe=2m --labels=gaterun=1,type=viacli

sleep 60s

echo 'Gate run #2'
for i in {1..20}
do
  curl --silent --output nul --show-error 'http://35-192-62-255.nip.io:8070/api/echo?text=Just%20say%20whatever%20you%20want&sleep=800'
done

sleep 60s

keptn send event start-evaluation --project=standalone-qg --stage=qualitystage --service=simplenodeservice --timeframe=2m --labels=gaterun=2,type=viacli

sleep 60s

echo 'Gate run #3'
for i in {1..20}
do
  curl --silent --output nul --show-error 'http://35-192-62-255.nip.io:8070/api/echo?text=Just%20say%20whatever%20you%20want&sleep=600'
done

for i in {1..5}
do
  curl --silent --output nul --show-error 'http://35-192-62-255.nip.io:8070/api/invoke?url=https://www.amazon.com&sleep=900'
done

sleep 60s

keptn send event start-evaluation --project=standalone-qg --stage=qualitystage --service=simplenodeservice --timeframe=2m --labels=gaterun=3,type=viacli

