#!/bin/bash

##########################################   HISTORY ##################################################
#												      #
#  Created by Tim Kimpton 									      #
#												      #
#  27/2/2013											      #
#												      #
#  Version 1.5											      #
#												      #
# This is used with a launch daemon to run the script every time a volume is mounted		      #
#                                                                                                     #
# This script will search if there is removable media and will automatically scan the media           #
#                                                                                                     #
# If there is a virus the system tries to "touch the file" which activate the SAV Quarantine Manager  #
#                                                                                                     #
#######################################################################################################

# Get the disk name of the removable Media
for disk in $(diskutil list | awk '/disk[1-9]s/{ print $NF }' | grep -v /dev); do
if [[ $(diskutil info $disk | awk '/Protocol/{ print $2 }' | egrep "USB|FireWire|SATA") != "" ]]; then
diskName=$(diskutil info $disk | awk -F: '/Mount Point/{print $NF}' | sed 's/^[ \t]*//' )


# Use the Sophos Anti-Virus sweep command to scan the removable media
sav=`/usr/bin/sweep "$diskName" | grep ">>> Virus" | cut -d"'" -f3 | cut -c 16- | sed 's/ /\\ /g'`

# Touch the file to Triggeer the Sophos Quarantine Manager
touch "$sav"

fi
done



