#!/bin/sh
## postflight
##
## Not supported for flat packages.

pathToScript=$0
pathToPackage=$1
targetLocation=$2
targetVolume=$3

######################################################################
# NOTE:  The VMware Horizon Client App does NOT like being packaged
# and insists upon being copied from vendor .dmg to ensure okay usage
# This custom installer by Christopher Miller, Dated: 20150921
# for ITSD-ISS of JHU-APL
# !!!! Modify this script as needed for future vendor .dmg files !!!!
######################################################################

####################################################################
### Specify the name and location of the vendor's .dmg file here ###
# This assumes vendor .dmg is in "/private/var/tmp" as pkg payload #
####################################################################
VendorDMG="/private/var/tmp/VMware-Horizon-Client-3.5.0-2999900.dmg"

#######################################################
# Check for the presence of the Vendor .dmg file
if [ -e "$VendorDMG" ]
	then
		# Mount the vendor .dmg file
		echo "Mounting $VendorDMG"
		hdiutil attach "$VendorDMG" -nobrowse
		sleep 3
	else 
		echo "Vendor .dmg file not found, look for $VendorDMG"
		echo "Exiting script, please verify name and location of .dmg"
		exit 1	#Stop HERE#
fi

###################################################
# If present, Remove the earlier copies of the VMware Horizon Client from /Applications
# Start a running count of old apps we find
###################################################
OldCopy=0

# Look for older client name version
if [ -e "/Applications/VMware View Client.app" ]
then 
	let "OldCopy=OldCopy+1"
	echo "Found VMware View, now removing"
	rm -Rf "/Applications/VMware View Client.app"
fi

# Look for not quite as old client name version	
if [ -e "/Applications/VMware Horizon View Client.app" ]
then
	let "OldCopy=OldCopy+1"
	echo "Found VMware Horizon View, now removing"
	rm -Rf "/Applications/VMware Horizon View Client.app"
fi 

# Look for current name copy of Application
if [ -e "/Applications/VMware Horizon Client.app" ]
	then 
		let "OldCopy=OldCopy+1"
		echo "Removing original App"
		sudo rm -Rf "/Applications/VMware Horizon Client.app"
		sleep 3
fi

# Report what was found when looking for older copies
if [ Oldcopy != 0 ]
	then
		# Report older name versions found
		echo "Found $OldCopy Older .app copies"
	else
		# Report no older copies found
		echo "No older named .apps found"
fi

####################################################
# Copy the .app from the mounted vendor .dmg volume
# If App name changes, the next line needs modified 
####################################################
cp -Rf "/Volumes/VMware Horizon Client/VMware Horizon Client.app" "/Applications/VMware Horizon Client.app"
sleep 3

# Check if the copy completed and .app is present, modify via chown and chmod
if [ -e "/Applications/VMware Horizon Client.app" ]
	then 
		echo "Application successfully copied"
		sudo chown root:wheel "/Applications/VMware Horizon Client.app"
		sudo chmod 755 "/Applications/VMware Horizon Client.app"
	
	else
		echo "Application not found!, check the $VendorDMG file"
fi

# UnMount the vendor .dmg file, remove the vendor.dmg as cleanup
echo "UnMounting $VendorDMG"
hdiutil detach "/Volumes/VMware Horizon Client"
sleep 3
sudo rm -Rf "$VendorDMG"

echo "Finished! Check status messages above"

exit 0		## Success
exit 1		## Failure