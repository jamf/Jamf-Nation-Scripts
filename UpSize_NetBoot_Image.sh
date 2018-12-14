##########################################
# Written by Christopher Miller for ITSD-ISS of JHU-APL
# Cobbled together from other's hard work
# Dated 20140116
##########################################
# This will resize the NetBoot.dmg files 
# created by 10.8, 10.9 OS X Server's System Image Utility
# Copy, DON'T MOVE, this script to .nbi folder 
# needing modification.  Open Terminal and 
# start the script by typing the following:  
# "sh UpSize_NetBoot_Image.sh"
##########################################
# Versions: 10.8, 10.9, 10.10

# Rename the Original NetBoot image to NetBoot-old
mv NetBoot.dmg NetBoot-old.dmg

# Convert the Original NetBoot image and create a Sparse Disk Image
hdiutil convert NetBoot-old.dmg -format UDSP -o NetBoot-old.rw.dmg

# Resize the Sparse Disk Image to 40 GBs allocation
# You may alter the intended size by changing the
# value after "-size XXg below #
hdiutil resize -size 40g NetBoot-old.rw.dmg.sparseimage

# Convert the Sparse Image to Read Only and create an Image with the correct name
hdiutil convert NetBoot-old.rw.dmg.sparseimage -format UDRO -o NetBoot.dmg

# Remove the Original and Sparse Disk Images
rm NetBoot-old.dmg
rm NetBoot-old.rw.dmg.sparseimage

echo "Finished!"

# Self Destruct this script
rm $0

exit 0
