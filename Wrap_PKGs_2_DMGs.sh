#!/bin/sh
#################################################################
# Make .DMGs from a collection of .PKGs
# By Christopher Miller 
# For ITSD-ISS of JHU-APL
# Dated: 2016-12-14, LastMod: 2016-12-14
# Drop this Script into the Package collection folder
# This should avoid non .PKG files
#################################################################

#################################################################
# Build a list of PKGs to be worked through
# Avoid Package File Names with spaces, this can break the list
#################################################################
PKGFileList=$(ls | grep .pkg)

# Invoke Hard Disk Image Utility (hdiutil) to process through list of PKGs
for i in $PKGFileList ; do 
	echo "Now Wrapping $i"
	hdiutil create -fs HFS+ -srcfolder "$i" "$i".dmg ; echo
done

# Signal when done.
echo "All Done!"

exit 0