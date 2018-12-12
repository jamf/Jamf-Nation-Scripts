#!/bin/sh

# Set some Variables
SupportContactInfo="your system administrator."
dmgfile="GoogleDriveFileStream.dmg"
logfile="/Library/Logs/GoogleFileStreamInstallScript.log"
url="https://dl.google.com/drive-file-stream/GoogleDriveFileStream.dmg"
user=`ls -l /dev/console | cut -d " " -f 4`

# Say what we are doing
/bin/echo "`date`: Installing latest version of File Stream for $user..." >> ${logfile}

# Download All the Things
/bin/echo "`date`: Downloading the latest version of File Stream from Google's servers" >> ${logfile}
/usr/bin/curl -k -o /tmp/$dmgfile $url
/bin/echo "`date`: Mounting dmg file." >> ${logfile}
/usr/bin/hdiutil attach /tmp/$dmgfile -nobrowse -quiet

# Install the things. 
/bin/echo "`date`: Installing pkg" >> ${logfile}
/usr/sbin/installer -pkg /Volumes/Install\ Google\ Drive\ File\ Stream/GoogleDriveFileStream.pkg -target /

# Look for Google Drive
if [ -d /Applications/Google\ Drive.app/ ]; then
  /bin/echo "`date`: Found depricated version of Google Drive. Stopping Drive service." >> ${logfile}
  /usr/bin/osascript -e 'tell application "Google Drive" to quit'
  /bin/echo "`date`: Deleting Google Drive Application." >> ${logfile}
  rm -Rf /Applications/Google\ Drive.app/
  /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper  -title "Google Drive Version Found" -windowType hud -description "Google Drive Version Found" -description "While installing Google Drive File Stream we found an older version of Google Drive. Since they are not compatible, we removed the older version. However, you still have data stored in your home folder under Google Drive. These files will no longer be synced, so you should either move them or delete them. If you have any addional questions please reach out to ${SupportContactInfo}." &
fi

# Cleanup Tasks
/bin/echo "`date`: Unmounting installer disk image." >> ${logfile}
/usr/bin/hdiutil detach $(/bin/df | /usr/bin/grep "Install Google File Stream" | awk '{print $1}') -quiet
/bin/echo "`date`: Deleting temp files." >> ${logfile}
rm -fv /tmp/$dmgfile
/bin/sleep 3
/bin/echo "`date`: Launching File Stream" >> ${logfile}
open -a /Applications/Google\ Drive\ File\ Stream.app/
/bin/echo "`date`: Finished." >> ${logfile}

exit 0
