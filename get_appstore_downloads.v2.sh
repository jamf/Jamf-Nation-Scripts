#!/bin/sh

#	Author: 	Andrew Thomson
#	Date: 		3/19/2014

#	This script can be used to capture downloaded package files from the Mac App Store so the apps can be redistributed.
#	The package files will retain their Apple developer certificates but will NOT include the _MASReceipt from the App Store.
#	These redistributable packages are ideal for use with Casper but it does mean subsequent updates will similarly have
#	to be downloaded and distributed. Obviously this defeats the design of the App Store model, and should only be used with
#	legally purchased or free apps. Use at your own risk. 

#	Usage: Launch the script before clicking the "Install" button for a specific app in the Mac App Store. Once the selected 
#	app begins to download and install on your local system, a copy (linked file) of the associated installer package will 
#	will be added to your profile's desktop location (~/Desktop). Once a package file is detected and copied to your desktop, 
#	wait until the App Store indicates the app is fully downloaded and installed on your system before atempting to rename or move 
#	the desktop copy. Failure to do so could lead to a corrupt package file. Use at your own risk. 

#	declare root of file search
searchPath="/var/folders/"

#	set found to false to start
found=false

#	loop thru looking for app store packages until one is found
until $found; do
	#	get list of package files
	packageList=$(find $searchPath -name "mzp*.pkg" 2> /dev/null)

	#	link any found package files to desktop folder
	if [ ! -z $packageList ]; then
		for file in $packageList; do
			fileName=$(/usr/bin/basename $file)
			/bin/ln $file ~/Desktop/$filename
		done
		found=true		
	fi
done