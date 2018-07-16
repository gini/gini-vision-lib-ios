#!/bin/bash

infoPlist="Example/Example Swift/Info.plist"
hockey_api_key=$1
hockey_app_id=$2

hockeyLastBuildNumber=$(curl -H "X-HockeyAppToken: $hockey_api_key" https://rink.hockeyapp.net/api/2/apps/$hockey_app_id/app_versions | python -c "import sys, json; print json.load(sys.stdin)['app_versions'][0]['version']")

#Build number bump
buildNumber=$(($hockeyLastBuildNumber + 1))
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "$infoPlist"
