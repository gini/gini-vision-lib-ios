#!/bin/bash

infoPlist="Example/GiniVision/Info.plist"

#Build number bump
buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$infoPlist")
buildNumber=$(($buildNumber + 1))
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "$infoPlist"

# git add .
# git commit -m "Bumped Example app build number to $buildNumber"
# git push
