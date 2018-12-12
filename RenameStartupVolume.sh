#!/bin/sh

##########################################
# Rename Startup Volume 				 
# Josh Harvey | Jul 2017				 
# josh[at]macjeezy.com 				 	 
# GitHub - github.com/therealmacjeezy    
# JAMFnation - therealmacjeezy			 
##########################################

############################### Notes ##################################
# This script will find the boot volume using the bless command
# and then get the current volume name for the boot volume using
# the diskutil command. It will then find the short version of 
# macOS the computer has installed.
# 
# The reason for this script is so that the startup volume names
# are uniformed based off of the macOS version they have installed.
# The variable "newName" is then assigned a string based off of the
# macOS version installed. This variable is then compaired to the
# current volume name. If the names do not match, it will automatically
# rename the startup volume to the correct name.
#
########### ISSUES / USAGE #############################################
# If you have any issues or questions please feel free to contact  	    
# using the information in the header of this script.                   
#																		
# Also, Please give me credit and let me know if you are going to use  
# this script. I would love to know how it works out and if you find    
# it helpful.  														    
########################################################################


# Finds the current boot volume
bootVolume=`/usr/sbin/bless --info --getboot`

# Uses the variable above to pull the name of the boot volume
bootVolumeName=`/usr/sbin/diskutil info $bootVolume | grep "Volume Name" | sed 's/.*://g' | awk '{$1=$1};1'`

# Finds the OS version installed on the computer
osVersion=`/usr/bin/sw_vers -productVersion`

# Finds the correct Volume Name for the macOS version
if [[ "$osVersion" =~ "10.11" ]];
	then
		newName="macOS1011"
elif [[ "$osVersion" =~ "10.12" ]];
	then
		newName="macOS1012"
fi

# Compares the current volume name to the one that it's supposed to have based off the variables set above
if [[ "$bootVolumeName" == "$newName" ]];
	then
		validName="Yes"
	else
		validName="No"
fi

# If the volume name is invalid, it will be renamed to the correct name
if [[ "$validName" == "No" ]];
	then
		/usr/sbin/diskutil rename "$bootVolume" "$newName"
else
		echo "Current Volume Name is Valid"
fi