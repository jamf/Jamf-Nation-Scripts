#!/bin/bash

#----------------------------------------------------------------------------------------
# Dev: Aaron Baumgarner
# Created: 29 July 2015
# Refreshed by Tim Kimpton 17th May 2017
# Updated to properly echo version, and updated to faster download mirror by Hector Castaneda, 6th July 2017
# Description: This script is used to download and install one version behind the latest VLC.
#----------------------------------------------------------------------------------------

# Queries VLC's website for one version behind the latest.
vlc_version=`/usr/bin/curl http://mirror.nexcess.net/videolan/vlc/2.2.6/macosx/ | grep vlc- | cut -d \" -f 2 | awk '{printf("%s",$0);}' | cut -d . -f 1-3 | cut -d "/" -f 2`

echo $vlc_version

# Creates the download url based on the version pulled from the website
fileURL="http://mirror.nexcess.net/videolan/vlc/2.2.6/macosx/"$vlc_version".dmg"


echo $fileURL

vlc_dmg="/tmp/vlc.dmg" 

#Download latest VLC based on the url created
/usr/bin/curl --output /tmp/vlc.dmg "$fileURL"


#Mount the .dmg
hdiutil attach "$vlc_dmg" -nobrowse -noverify -noautoopen

vol_name=$(ls /Volumes/ | grep vlc)

sleep 10
#Installs VLC
cp -r /Volumes/"$vol_name"/VLC.app /Applications/

if [ -d /Applications/VLC.app ]; then
chown -R root:admin /Applications/VLC.app
chmod -R 775 /Applications/VLC.app
fi

#Cleanup
/usr/bin/hdiutil detach -force /Volumes/"$vol_name"
/bin/rm -rf "$vlc_dmg"

exit 0
