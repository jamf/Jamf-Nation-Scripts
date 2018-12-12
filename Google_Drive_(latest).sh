#!/bin/sh -x

logfile="/Library/Logs/jss.log"
user=`ls -l /dev/console | cut -d " " -f 4`
PRODUCT="Google Drive"
app_name="/Applications/Google Drive.app"

# test for Google Drive and gain version is exists
if [ -e "$app_name" ]
    then 
        version=$(grep -A1 CFBundleVersion "$app_name/Contents/Info.plist" | grep -oE '[[:digit:].]+')
        echo "Google Drive is installed running version.$version"
    else
# installation
    echo "$app_name does not exist."
    /bin/echo "`date`: Installing Google Drive for $user..."  >> ${logfile}
    dmgfile="image.dmg"
    volname="Install Google Drive"
    url="https://dl.google.com/drive/installgoogledrive.dmg"
    /bin/echo "`date`: Downloading $PRODUCT." >> ${logfile}
    /usr/bin/curl -k -o /tmp/image.dmg $url
    /bin/echo "`date`: Mounting installer disk image." >> ${logfile}
    /usr/bin/hdiutil attach /tmp/image.dmg -nobrowse -quiet
    /bin/echo "`date`: Installing..." >> ${logfile}
    cp -R /Volumes/Install\ Google\ Drive/Google\ Drive.app /Applications/
    /bin/sleep 3
    /bin/echo "`date`: Unmounting installer disk image." >> ${logfile}
    /usr/bin/hdiutil detach $(/bin/df | /usr/bin/grep "${volname}" | awk '{print $1}') -quiet
    /bin/sleep 3
    open -a /Applications/Google\ Drive.app/
# /installation
fi