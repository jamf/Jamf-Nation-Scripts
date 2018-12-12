#!/bin/bash

#################################################
# Apple Software Update Search
# Version: 2.0
# Josh Harvey | Jul 2017
# josh[at]macjeezy.com
# Updated: Feb 2018
# GitHub - github.com/therealmacjeezy
# JamfNation - therealmacjeezy
#################################################

############################# Change Log ##############################
## Version 2.0 Update (Feb 2018)
# - Added support for multiple updates to used in the script parameters
# (current limit is 4, version 1.0 only supported one item at a time)
#
# - Rewrote the way updates are handled. Now any update that is found gets 
# added to an array then is downloaded to the default location (/Library/Updates/).
# Once the update is finished downloading, it gets added to another array
# which is then used to install each update after they all have been downloaded.
#
# - Added a section that will check to see if the update requires a restart.
# If it's required, it will set the "restartRequired" variable to yes. Once all
# updates have been downloaded and installed, a if statement checks the restart
# variable and will trigger a policy setup for an delayed authenticated reboot.
# NOTE: A policy will have to be created with a matching trigger in order for this
# feature to work. This section currently only looks for the "security" label.
#
# - Added a manual inventory update before the restartRequired check to ensure
# any installed updates are succesfully reflected in the Jamf Pro Server. (This
# was written in to work around an issue where inventory updates would fail if
# the update name exceeded a certain amount of characters.) 
########################### USAGE / ISSUES ############################
# Enter the item(s) you are trying to update in Parameters 4 through 7.
#
# If you want an authenticated reboot to occur if required by an update
# you will need to create a policy with a custom trigger (Set to Ongoing).
# 
# If you have any issues or questions please feel free to contact  	    
# using the information in the header of this script.
#
# If an item doesn't have any available updates, it will move onto the
# next item (if entered). If no updates for any of the items are found
# it will exit quietly.
#
# Also, Please give me credit and let me know if you are going to use  
# this script. I would love to know how it works out and if you find    
# it helpful.
#######################################################################

##### Script Parameters #####
# Parameter 4 - Update Selection (Required)
# Parameter 5 - Update Selection (Optional)
# Parameter 6 - Update Selection (Optional)
# Parameter 7 - Update Selection (Optional)
##### Parameter Options #####
# iTunes - iTunes Update
# macOS - macOS Software Update (Restart Required)
# RDP - Remote Desktop Client Update
# Security - Security Update (Restart Required)
# App Store - Mac App Store Update (Restart Required)
# Safari - Safari Update

formatInput() {
	# Arrays that contain multiple variations of each item to ensure it gets formatted correctly
	RemoteDesktop=("rdp" "RDP" "remote desktop" "remote" "Remote" "Remote Desktop")
	iTunes=("itunes" "Itunes" "iTunes")
	macOS=("macos" "MacOS" "MACOS" "osx" "OSX")
	appStore=("app" "appstore" "App Store" "App store" "Appstore")
	security=("Security" "security" "security update" "Security Update")
	safari=("safari" "Safari")

	# Formats the item name
	if [[ "${iTunes[@]}" =~ "$itemUpdate" ]]; then
		itemUpdate="iTunes"
	elif [[ "${macOS[@]}" =~ "$itemUpdate" ]]; then
		itemUpdate="macOS"
	elif [[ "${RemoteDesktop[@]}" =~ "$itemUpdate" ]]; then
		itemUpdate="RemoteDesktop"
	elif [[ "${appStore[@]}" =~ "$itemUpdate" ]]; then
		itemUpdate="App Store"
	elif [[ "${security[@]}" =~ "$itemUpdate" ]]; then
		itemUpdate="Security"
	elif [[ "${safari[@]}" =~ "$itemUpdate" ]]; then
		itemUpdate="Safari"
	fi
}

# Creates an empty array
updateList=()

# Checks for input in each of the parameters and formats the string for use in the softwareupdate command
if [[ ! -z "$4" ]]; then
	itemUpdate="$4"
	formatInput
	updateList+=($itemUpdate)
else
	echo "Parameter 4 is missing and is required."
	exit 0
fi

# Parameter 5 (Optional)
if [[ ! -z "$5" ]]; then
	itemUpdate="$5"
	formatInput
	updateList+=($itemUpdate)
else
	echo "Parameter 5 is empty."
fi

# Parameter 6 (Optional)
if [[ ! -z "$6" ]]; then
	itemUpdate="$6"
	formatInput
	updateList+=($itemUpdate)
else
	echo "Parameter 6 is empty."
fi

# Parameter 7 (Optional)
if [[ ! -z "$7" ]]; then
	itemUpdate="$7"
	formatInput
	updateList+=($itemUpdate)
else
	echo "Parameter 7 is empty."
fi

# Sets the update count variable to zero then looks at the updateList array and checks to see if an update is available and if so downloads the update to /Library/Updates for each item
updateCount="0"
for i in "${updateList[@]}"; do
	echo "Searching for an update for ${updateList[$updateCount]} .."
	# Variable that searches for available software updates for the item
	searchUpdate=$(/usr/sbin/softwareupdate -l | grep -w "*" | sed 's/^[[:space:]]*//' | grep -y "${updateList[$updateCount]}" | sed 's/[*]//g' | sed 's/^[[:space:]]*//')
		# Checks to see if there is an update available, if not it will return No Update Found and continue to the next item
		if [[ -z "$searchUpdate" ]]; then
			echo "No update found for ${updateList[$updateCount]} .."
		else
			echo "Update found for ${updateList[$updateCount]} .. Starting download."
			installList+=("$searchUpdate")
			/usr/sbin/softwareupdate -d "$searchUpdate"
			echo "Download of "${updateList[$updateCount]}" finished"
		fi	
	let updateCount+=1
done

# Sets the install count variable to zero then looks at the installList array and runs the softwareupdate command with the install flag for each item in the array
installCount="0"
for i in "${installList[@]}"; do
	echo "Installing the update for "${installList[$installCount]}" ..."
	/usr/sbin/softwareupdate -i "${installList[$installCount]}"
	echo "Installation of "${installList[$installCount]}" is complete."
	let installCount+=1
done

# Updates the inventory to reflect the installed updates
sudo /usr/local/bin/jamf recon

# Lists the updates that were installed
echo "The following updates have been installed:"
echo "${installList[@]}"

# Checks to see if a restart is required
if [[ "${installList[@]}" =~ Security ]]; then
	echo "A restart is required for this update"
	restartRequired="yes"
else
	restartRequired="no"
fi

# Checks the restart variable to see if a restart is required and if so runs the trigger for a policy set to perform an authenticated restart
if [[ "$restartRequired" == "yes" ]]; then
	echo "Restart is Required"
	# Edit the line below to match the policy in the Jamf Pro server
	sudo /usr/local/bin/jamf policy -event securityReboot
else
	echo "No Restart Required"
fi