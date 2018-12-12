#!/bin/sh
## postflight
##
## Not supported for flat packages.

pathToScript=$0
pathToPackage=$1
targetLocation=$2
targetVolume=$3

######################################################################
# NOTE:  Some Vendor Applications do NOT like being packaged
# and insists upon being copied from vendor .dmg to ensure okay usage
# This custom installer by Christopher Miller, Dated: 20150921
# for ITSD-ISS of JHU-APL
# !!!! Modify this script as needed for future vendor .dmg files !!!!
######################################################################

# Specify the name & location of the vendor's .dmg file, the name of the mounted disk, the name of the Application
# Recommend placing the Vendor .DMG file into /private/var/tmp/ location for the payload
VendorDMG=""	#The full path to the Vendor .DMG file
VendorDisk=""	#The volume name of the mounted .DMG
VendorAPP=""	#The name of the Application being installed, for removal of old copies prior to install

# Check for the presence of the Vendor .dmg file
if [ -e "$VendorDMG" ]
	then
		# Mount the vendor .dmg file
		echo "Mounting $VendorDMG"
		hdiutil attach "$VendorDMG" -nobrowse
		sleep 3
	else 
		echo "Vendor .dmg file not found, look for $VendorDMG"
		echo "exiting script, please verify name and location of .dmg"
		exit 1	#Stop HERE#
fi


# If present, Remove the earlier copy of the Vendor App from /Applications
if [ -e "/Applications/$VendorAPP" ]
	then 
		echo "Removing original App"
		sudo rm -Rf "/Applications/$VendorAPP"
		sleep 3
	
	else
		echo "Older Application not found, beginning copy"
fi


# Copy the .app from the mounted .dmg volume
cp -Rf "/Volumes/$VendorDisk/$VendorAPP" "/Applications/$VendorAPP"
sleep 3

# Check if the copy completed and .app is present, modify via chown and chmod
if [ -e "/Applications/$VendorAPP" ]
	then 
		echo "Application successfully copied"
		sudo chown root:wheel "/Applications/$VendorAPP"
		sudo chmod 775 "/Applications/$VendorAPP"
	
	else
		echo "Application not found!, check the $VendorDMG file"
fi

# UnMount the vendor .dmg file, remove the vendor.dmg as cleanup
echo "UnMounting $VendorDMG"
hdiutil detach "/Volumes/$VendorDisk"
sleep 3
sudo rm -Rf "$VendorDMG"

echo "Finished! Check status messages above"

exit 0		## Success
exit 1		## Failure