#!/bin/bash
USERNAME=$(cat /home/pi/.homeassistant/netatmo/secrets.txt | cut -d , -f1)
PASSWORD=$(cat /home/pi/.homeassistant/netatmo/secrets.txt | cut -d , -f2)

#Start session
curl -s -c /home/pi/.homeassistant/netatmo/cookies.txt -b /home/pi/.homeassistant/netatmo/cookies.txt https://auth.netatmo.com/en-US/access/login > /dev/null
#Grab CSRF
CSRF=$(cat /home/pi/.homeassistant/netatmo/cookies.txt | grep csrf | cut -f7 -d$'\t')
#Authenticate
curl -s -c /home/pi/.homeassistant/netatmo/cookies.txt -b /home/pi/.homeassistant/netatmo/cookies.txt https://auth.netatmo.com/en-US/access/login --data 'ci_csrf_netatmo='"$CSRF"'&mail='"$USERNAME"'&pass='"$PASSWORD"'&log_submit=LOGIN&stay_logged=accept' > /dev/null
# #Grab Status
ACCESSTOKEN=$(cat /home/pi/.homeassistant/netatmo/cookies.txt | grep netatmocomaccess_token | cut -f7 -d$'\t' | sed 's/%7C/|/g')
#jq grabs the status from json, sed strips the quotes
curl -s -b /home/pi/.homeassistant/netatmo/cookies.txt https://my.netatmo.com/api/gethomedata -H 'Authorization: Bearer '"$ACCESSTOKEN"'' -H 'Origin: https://my.netatmo.com' -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept: application/json, text/plain, */*' -H 'Referer: https://my.netatmo.com/app/camera' --data-binary '{}' | jq .body.homes[0].cameras[0].status | sed -e 's/^"//' -e 's/"$//'