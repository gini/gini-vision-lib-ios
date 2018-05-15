#!/bin/bash

client_id=$1
client_password=$2

printf '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>client_password</key>
	<string>'$client_password'</string>
	<key>client_id</key>
	<string>'$client_id'</string>
	<key>client_domain</key>
	<string>gini.net</string>
</dict>
</plist>' > Example/Credentials.plist
