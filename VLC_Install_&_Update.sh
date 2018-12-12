#!/bin/bash

#----------------------------------------------------------------------------------------
# Dev: Aaron Baumgarner
# Created: 29 July 2015
# Modified by Tim Kimpton 17th May 2017
# Modified by Bill Cheney 5th July 2018 (fixed for version 3 changes)
# Description: This script is used to download and install one version behind the latest VLC.
#----------------------------------------------------------------------------------------

# Queries VLC's website for one version behind the latest.
vlc_version=`/usr/bin/curl http://mirror.wdc1.us.leaseweb.net/videolan/vlc/last/macosx/ | grep vlc- | cut -d \" -f 2 | awk '{printf("%s",$0);}' | cut -d . -f 3-5 | cut -d "/" -f 2`


# Creates the download url based on the version pulled from the website
fileURL="http://mirror.wdc1.us.leaseweb.net/videolan/vlc/last/macosx/"$vlc_version".dmg"

vlc_dmg="/tmp/vlc.dmg" 

#Download latest VLC based on the url created
/usr/bin/curl --output /tmp/vlc.dmg "$fileURL"


#Mount the .dmg
hdiutil attach /tmp/vlc.dmg -nobrowse -noverify -noautoopen
sleep 10

#Deletes Old VLC (crashing when overwriting 2.2+ to 3)

sudo rm -rf /Applications/VLC.app

#Installs New VLC

cp -r /Volumes/VLC\ media\ player/VLC.app /Applications/

if [ -d /Applications/VLC\ media\ player.app ]; then
chown -R root:admin /Applications/VLC.app
chmod -R 775 /Applications/VLC.app
fi

#Cleanup
/usr/bin/hdiutil detach -force /Volumes/VLC\ media\ player
/bin/rm -rf "$vlc_dmg"

exit 0