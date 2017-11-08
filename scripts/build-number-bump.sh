#!/bin/bash

infoPlist="Example/GiniVision/Info.plist"

hockeyLastBuildNumber=$(curl -H "X-HockeyAppToken: 044a1b5cec5946ff960e9bd646486f27" https://rink.hockeyapp.net/api/2/apps/c9a58ca1b2b14e6d9d5f463ae91d35b6/app_versions | python -c "import sys, json; print json.load(sys.stdin)['app_versions'][0]['version']")

#Build number bump
buildNumber=$(($hockeyLastBuildNumber + 1))
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "$infoPlist"
