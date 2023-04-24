#!/bin/bash

source /usr/local/scripts/tydtemp/tydtempvars.sh

acctok=$(curl -s -L -X POST "https://www.googleapis.com/oauth2/v4/token?client_id=${client_id}&client_secret=${client_secret}&refresh_token=${refresh_token}&grant_type=refresh_token" | jq -r '.access_token')

/usr/local/bin/pixlet render /usr/local/scripts/tydtemp/tydtemp.star pid=$project_id auth=$acctok -o /tmp/tidtemp.webp

/usr/local/bin/pixlet push -b -t $tydbyt_api_key --installation-id TydTemp $tydbyt_device_id /tmp/tidtemp.webp
