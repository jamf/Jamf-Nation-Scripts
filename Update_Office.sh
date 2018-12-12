#!/bin/bash

currentUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
MAU_PLIST_PATH="/Users/$currentUser/Library/Preferences/com.microsoft.autoupdate2.plist"

function setUpdateTime(){
	/usr/libexec/PlistBuddy -c "Delete :UpdateCheckFrequency" $MAU_PLIST_PATH
	/usr/libexec/PlistBuddy -c "Add :UpdateCheckFrequency integer $1" $MAU_PLIST_PATH
}

# metdata URL
META_DATA_URL="https://officecdn.microsoft.com/pr/C1297A47-86C4-4C1F-97FA-950631F94777/OfficeMac/0409MSau03.xml"

# fetch the PLIST
XML=`curl -s -L $META_DATA_URL`

# save PLIST
echo $XML > /tmp/MAU.plist

# what the new updater PKG is called
DOWNLOAD_PKG_NAME=`/usr/libexec/PlistBuddy -c "print 0:Payload" /tmp/MAU.plist`

# URL where the PKG is located
DOWNLOAD_URL=`/usr/libexec/PlistBuddy -c "print 0:Location" /tmp/MAU.plist`

# download the PKG
curl -s -L -o /tmp/$DOWNLOAD_PKG_NAME $DOWNLOAD_URL

# kill office stuff
pkill -9 "Microsoft AutoUpdate" > /dev/null
pkill -9 "Microsoft Outlook" > /dev/null
pkill -9 "Microsoft Excel" > /dev/null
pkill -9 "Microsoft Word" > /dev/null
pkill -9 "Microsoft PowerPoint" > /dev/null
sleep 1
pkill -9 "Microsoft Error Reporting" > /dev/null

# install the PKG
sudo /usr/sbin/installer -pkg /tmp/$DOWNLOAD_PKG_NAME -target /

setUpdateTime "1"

/usr/libexec/PlistBuddy -c 'Delete :LastUpdate' $MAU_PLIST_PATH
/usr/libexec/PlistBuddy -c 'Add :LastUpdate string 2000-01-01T01:00:00Z' $MAU_PLIST_PATH

open "/Applications/Microsoft Outlook.app"

sleep 5

# revert back to the default time
setUpdateTime "720"

exit 0