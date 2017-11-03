#!/bin/bash

infoPlist="Example/GiniVision/Info.plist"

#Build number bump
buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$infoPlist")
buildNumber=$(($buildNumber + 1))
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "$infoPlist"

#Version name bump
VERSIONNUM=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$infoPlist")

NEWSUBVERSION=`echo $VERSIONNUM | awk -F "." '{print $3}'`
NEWSUBVERSION=$(($NEWSUBVERSION + 1))

if [ $NEWSUBVERSION -gt 9 ]
then
    NEWSUBVERSION=`echo $VERSIONNUM | awk -F "." '{print $2}'`
    NEWSUBVERSION=$(($NEWSUBVERSION + 1))
    if [ $NEWSUBVERSION -gt 9 ]
    then
      NEWSUBVERSION=`echo $VERSIONNUM | awk -F "." '{print $1}'`
      NEWSUBVERSION=$(($NEWSUBVERSION + 1))
      NEWVERSIONSTRING=`echo $VERSIONNUM | awk -F "." '{print "'$NEWSUBVERSION'." 0 "." 0 }'`

    else
      NEWVERSIONSTRING=`echo $VERSIONNUM | awk -F "." '{print $1 ".'$NEWSUBVERSION'." 0 }'`
    fi
else
    NEWVERSIONSTRING=`echo $VERSIONNUM | awk -F "." '{print $1 "." $2 ".'$NEWSUBVERSION'" }'`
fi

/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $NEWVERSIONSTRING" "$infoPlist"

git add .
git commit -m "Bumped ExampleApp version to $NEWVERSIONSTRING($buildNumber)"
