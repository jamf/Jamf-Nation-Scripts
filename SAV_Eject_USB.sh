#!/bin/bash

######################################## HISTORY ###########################################################
#                                                                                                          #
# By Tim Kimpton                                                                                           #
#                                                                                                          #
# 21/2/2013                                                                                                #
#                                                                                                          #
# Version 1.0                                                                                              #
#                                                                                                          #
# To be used in conjunction with a launch daemon with watch paths to /Library/Logs/Sophos\ Anti-Virus.log  #
#                                                                                                          #
# If a SAV Threat is detected in the SAV log then the external device is ejected                           #
#                                                                                                          #
############################################################################################################

######################################## VARIABLES #########################################################

# Get the Volume name from the SAV log
diskName=`grep "Threat" /Library/Logs/Sophos\ Anti-Virus.log | grep "Volumes" | cut -d"/" -f3`

# Get the disk identifier
identifier=`diskutil list | grep "${diskName}" | awk '{print $7}'`

date=`date "+%d-%m-%y_%H.%M"`

################################# DO NOT MODIFY BELOW THIS LINE #############################################

# Check to see if Threat exists
if grep "Threat" /Library/Logs/Sophos\ Anti-Virus.log ;then

# Eject the volume
hdiutil eject -force "${identifier}"

# Rename the log
mv /Library/Logs/Sophos\ Anti-Virus.log /Library/Logs/"${date}"_Sophos\ Anti-Virus.log

# Update SAV to receate the log
/usr/bin/sophosupdate

fi
exit 0
