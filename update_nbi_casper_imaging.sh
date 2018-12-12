#!/bin/sh

#	This script was written to automatically update the version of the Casper Imaging application on any NetBoot image
#	where an older version of the application is found (OS X only). This script can be run from the JSS against all 
#	NetBoot servers provided an updated version of the Casper Imaging application has previously been installed in the
#	Applications folder. NetBoot images without a previous version of Casper Imaging will not be affected. 

#	Author:		Andrew Thomson
#	Date:		08-16-2016 


IFS=$'\n'
DEBUG=true

function cleanUp() {
	#	unmount disk image
	if [ -d "$MOUNT_POINT" ]; then /usr/bin/hdiutil eject $MOUNT_POINT &> /dev/null; fi
}


#	make sure to cleanup on exit
trap cleanUp EXIT


# 	make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "ERROR: This script must be run as root" 
   exit $LINENO
fi


#	check for serveradmin utility
if ! PATH_SERVERADMIN=`/usr/bin/which serveradmin`; then
	echo "ERROR: Unable to find serveradmin utility."
	exit $LINENO
fi
if $DEBUG; then echo "SERVERADMIN: $PATH_SERVERADMIN"; fi


#	get path to source app
PATH_SOURCE_APP=(`/usr/bin/find /Applications -name "Casper Imaging.app" -type d -maxdepth 2`)
if [ ${#PATH_SOURCE_APP[@]} -ne 1 ]; then
	echo "ERROR: Unable to find source application."
	exit $LINENO
fi
if $DEBUG; then echo "SOURCE: $PATH_SOURCE_APP"; fi


#	get source app version
if ! VERSION_SOURCE_APP=`/usr/bin/defaults read "$PATH_SOURCE_APP/Contents/Info.plist" CFBundleShortVersionString | /usr/bin/sed -e 's/00//;s/[.]//g'`; then
	echo "ERROR: Unable to read source application version."
	exit $LINENO
fi
if $DEBUG; then echo "SOURCE VERSION: $VERSION_SOURCE_APP"; fi


#	check if netboot service is running
if ! "$PATH_SERVERADMIN" status netboot | /usr/bin/grep "RUNNING" &> /dev/null; then
	echo "ERROR: Netboot service is not running."
	exit $LINENO
fi


#	get path of info files
PATH_INFOS=(`"$PATH_SERVERADMIN" settings netboot | /usr/bin/awk -F'"' '/pathToImage/ {print $2}'`)
if [[ ${#PATH_INFOS[@]} -eq 0 ]]; then 
	echo "ERROR: Unable to find path to info files."
	exit $LINENO
fi
if $DEBUG; then echo "NBI COUNT: ${#PATH_INFOS[@]}"; fi
	

#	enumerate nbis
for PATH_INFO in ${PATH_INFOS[@]}; do
	
	#	get disk image name
	if ! DISK_IMAGE=`/usr/bin/defaults read "$PATH_INFO" RootPath`; then
		echo "ERROR: Unable to find disk image name."
		exit $LINENO
	fi
	if $DEBUG; then echo "IMAGE FILE: ${PATH_INFO%/*}/${DISK_IMAGE}"; fi

			
	#	mount disk image if file exists
	if [ -f "${PATH_INFO%/*}/${DISK_IMAGE}" ]; then
		MOUNT_POINT=`/usr/bin/hdiutil mount -owners on "${PATH_INFO%/*}/${DISK_IMAGE}" | /usr/bin/awk -F'[\t]' '/\/Volumes/{print $NF}'`
	else
		echo "ERROR: Unable to mount disk image."
		exit $LINENO
	fi
	if $DEBUG; then echo "MOUNT: $MOUNT_POINT"; fi
	

	#	get path to target app
	if ! PATH_TARGET_APP=(`/usr/bin/find ${MOUNT_POINT}/Applications -name "Casper Imaging.app" -type d -maxdepth 2`); then
		echo "ERROR: Unable to find target application."
		
		# 	clean up
		cleanUp
		
		#	skip to next image
		continue
	fi
	
	
	#	make sure only one target application found	
	if [ ${#PATH_SOURCE_APP[@]} -ne 1 ]; then
		echo "Unable to find target application."
		
		# 	clean up
		cleanUp
		
		#	skip to next image
		continue
	fi
	if $DEBUG; then echo "TARGET: $PATH_TARGET_APP"; fi
	
	
	#	get target app version
	if ! VERSION_TARGET_APP=`/usr/bin/defaults read "${PATH_TARGET_APP}/Contents/Info.plist" CFBundleShortVersionString | /usr/bin/sed -e 's/00//;s/[.]//g'`; then
		echo "ERROR: Unable to read target application version."
		exit $LINENO
	fi
	if $DEBUG; then echo "TARGET VERSION: $VERSION_TARGET_APP"; fi
	
	
	#	compare app versions
	if [[ $VERSION_SOURCE_APP -gt $VERSION_TARGET_APP ]]; then
		if $DEBUG; then echo "UPDATE: true"; fi
		
		#	remove target app
		if ! /bin/rm -rf "$PATH_TARGET_APP"; then
			echo "ERROR: Unable to remove target application."
			exit $LINENO
		fi
		
		#	copy uppdated app
		if ! /bin/cp -rf "$PATH_SOURCE_APP" "$PATH_TARGET_APP"; then 
			echo "ERROR: Unable to copy source application."
			exit $LINENO
		fi

		#	remove app from quarantine
		if ! /usr/bin/xattr -d -r com.apple.quarantine "$PATH_TARGET_APP"; then
			echo "ERROR: Unable to modify application attributes."
			exit $LINENO
		fi

		#	reset ownership
		if ! /usr/sbin/chown -R root:wheel "$PATH_TARGET_APP"; then 
			echo "ERROR: Unable to modify application ownership."
			exit $LINENO
		fi

		#	reset permissions
		if ! /bin/chmod -R 755 "$PATH_TARGET_APP"; then
			echo "ERROR: Unable to modify application permissions."
			exit $LINENO
		fi

	else 
		
		if $DEBUG; then echo "UPDATE: false"; fi
	fi
	
	# 	clean up
	cleanUp
done