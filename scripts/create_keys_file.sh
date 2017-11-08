#!/bin/bash

client_id=$1
client_password=$2

printf 'GINI_CLIENT_ID = \"'$client_id'\"\nGINI_CLIENT_SECRET = \"'$client_password'\"' > Example/Release-Keys.xcconfig
