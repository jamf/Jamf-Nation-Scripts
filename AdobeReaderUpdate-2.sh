#!/bin/sh
#####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#	AdobeReaderUpdate.sh -- Installs or updates Adobe Reader
#
# SYNOPSIS
#	sudo AdobeReaderUpdate.sh
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Joe Farage, 23.01.2015
#
####################################################################################################
# Script to download and install Adobe Reader.
# Only works on Intel systems.

dmgfile="reader.dmg"
logfile="/Library/Logs/AdobeReaderUpdateScript.log"

# Are we running on Intel?
if [ '`/usr/bin/uname -p`'="i386" -o '`/usr/bin/uname -p`'="x86_64" ]; then
	## Get OS version and adjust for use with the URL string
	OSvers_URL=$( sw_vers -productVersion | sed 's/[.]/_/g' )

	## Set the User Agent string for use with curl
	userAgent="Mozilla/5.0 (Macintosh; Intel Mac OS X ${OSvers_URL}) AppleWebKit/535.6.2 (KHTML, like Gecko) Version/5.2 Safari/535.6.2"

	# Get the latest version of Reader available from Adobe's About Reader page.
	latestver=`/usr/bin/curl -s -A "$userAgent" http://get.adobe.com/reader/ | /usr/bin/grep "<strong>Version" | /usr/bin/awk -F'[(|)]' '{print $2}'`
	echo "Latest Version is: $latestver"
	# Get the version number of the currently-installed Adobe Reader, if any.
	if [ -e "/Applications/Adobe Reader.app" ]; then
		currentinstalledver=`/usr/bin/defaults read /Applications/Adobe\ Reader.app/Contents/Info CFBundleShortVersionString`
		echo "Current installed version is: $currentinstalledver"
		if [ ${latestver} = ${currentinstalledver} ]; then
			echo "Adobe Reader is current. Exiting"
			exit 0
		fi
	else
		currentinstalledver="none"
		echo "Adobe Reader is not installed"
	fi
	
	ARCurrVersNormalized=$( echo $latestver | sed 's/[.]//g' )
	ARCurrMajVers=$( echo $latestver | cut -d. -f1 )
	url=""
	url1="http://ardownload.adobe.com/pub/adobe/reader/mac/${ARCurrMajVers}.x/${latestver}/en_US"
	url2="/AdbeRdr${ARCurrVersNormalized}_en_US.dmg"
	
	#Build URL	
	url=`echo "${url1}${url2}"`
	#url="http://aihdownload.adobe.com/bin/live/AdobeReaderInstaller_11_en_ltrosxd_aaa_aih.dmg"
	echo "Latest version of the URL is: $url"


	# Compare the two versions, if they are different or Adobe Reader is not present then download and install the new version.
	if [ "${currentinstalledver}" != "${latestver}" ]; then
        /bin/echo "`date`: Current Reader version: ${currentinstalledver}" >> ${logfile}
		/bin/echo "`date`: Available Reader version: ${latestver}" >> ${logfile}
		/bin/echo "`date`: Downloading newer version." >> ${logfile}
		/usr/bin/curl -s -o /tmp/reader.dmg ${url}
		/bin/echo "`date`: Mounting installer disk image." >> ${logfile}
		/usr/bin/hdiutil attach /tmp/reader.dmg -nobrowse -quiet
		/bin/echo "`date`: Installing..." >> ${logfile}
		/usr/sbin/installer -pkg /Volumes/AdbeRdr${ARCurrVersNormalized}_en_US/Adobe\ Reader\ XI\ Installer.pkg -target / > /dev/null
		
		/bin/sleep 10
		/bin/echo "`date`: Unmounting installer disk image." >> ${logfile}
		/usr/bin/hdiutil detach $(/bin/df | /usr/bin/grep AdbeRdr${ARCurrVersNormalized}_en_US | awk '{print $1}') -quiet
		/bin/sleep 10
		/bin/echo "`date`: Deleting disk image." >> ${logfile}
		/bin/rm /tmp/${dmgfile}
		
		#double check to see if the new version got updated
		newlyinstalledver=`/usr/bin/defaults read /Applications/Adobe\ Reader.app/Contents/Info CFBundleShortVersionString`
        if [ "${latestver}" = "${newlyinstalledver}" ]; then
            /bin/echo "`date`: SUCCESS: Adobe Reader has been updated to version ${newlyinstalledver}" >> ${logfile}
	   # /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType hud -title "Adobe Reader Updated" -description "Adobe Reader has been updated." &
        else
            /bin/echo "`date`: ERROR: Adobe Reader update unsuccessful, version remains at ${currentinstalledver}." >> ${logfile}
            /bin/echo "--" >> ${logfile}
			exit 1
		fi
    
	# If Adobe Reader is up to date already, just log it and exit.       
	else
		/bin/echo "`date`: Adobe Reader is already up to date, running ${currentinstalledver}." >> ${logfile}
        /bin/echo "--" >> ${logfile}
	fi	
else
	/bin/echo "`date`: ERROR: This script is for Intel Macs only." >> ${logfile}
fi

exit 0