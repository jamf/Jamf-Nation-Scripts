#!/bin/sh
#####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#	AdobeAIRUpdate.sh -- Installs or updates Adobe AIR
#
# SYNOPSIS
#	sudo AdobeAIRUpdate.sh
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.1
#
#	- Joe Farage, 16.03.2015, SITeL - Etat de Fribourg
#	- Jesse Miralia updated line 55 to https 
#
####################################################################################################
# Script to download and install Adobe AIR.
# Only works on Intel systems.

dmgfile="AdobeAIR.dmg"
logfile="/Library/Logs/AdobeAIRUpdateScript.log"

# Are we running on Intel?
if [ '`/usr/bin/uname -p`'="i386" -o '`/usr/bin/uname -p`'="x86_64" ]; then
	## Get OS version and adjust for use with the URL string
	OSvers_URL=$( sw_vers -productVersion | sed 's/[.]/_/g' )

	## Set the User Agent string for use with curl
	userAgent="Mozilla/5.0 (Macintosh; Intel Mac OS X ${OSvers_URL}) AppleWebKit/535.6.2 (KHTML, like Gecko) Version/5.2 Safari/535.6.2"

	# Get the latest version of AIR available from Adobe's About AIR page.
	latestver=`/usr/bin/curl -s -A "$userAgent" https://get.adobe.com/air/ | /usr/bin/grep "<strong>Version" | /usr/bin/sed -e 's/<[^>][^>]*>//g' -e '/^ *$/d' | /usr/bin/awk '{print $2}'`
	echo "Latest Version is: $latestver"
	# Get the version number of the currently-installed Adobe AIR, if any.
	if [ -e "/Applications/Utilities/Adobe AIR Application Installer.app" ]; then
		currentinstalledver=`/usr/bin/defaults read /Applications/Utilities/Adobe\ AIR\ Application\ Installer.app/Contents/Info CFBundleShortVersionString`
		echo "Current installed version is: $currentinstalledver"
		if [ ${latestver} = ${currentinstalledver} ]; then
			echo "Adobe AIR is current. Exiting"
			exit 0
		fi
	else
		currentinstalledver="none"
		echo "Adobe AIR is not installed"
	fi
	
	ARCurrVersNormalized=$( echo $latestver | sed 's/[.]//g' )
	ARCurrMajVers=$( echo $latestver | cut -d. -f1 )
	url=""
	url1="https://airdownload.adobe.com/air/mac/download/${latestver}"
	url2="/AdobeAIR.dmg"
	
	#Build URL
	url=`echo "${url1}${url2}"`
	echo "Latest version of the URL is: $url"


	# Compare the two versions, if they are different or Adobe AIR is not present then download and install the new version.
	if [ "${currentinstalledver}" != "${latestver}" ]; then
        /bin/echo "`date`: Current AIR version: ${currentinstalledver}" >> ${logfile}
		/bin/echo "`date`: Available AIR version: ${latestver}" >> ${logfile}
		/bin/echo "`date`: Downloading newer version." >> ${logfile}
		/usr/bin/curl -s -o /tmp/AdobeAIR.dmg ${url}
		/bin/echo "`date`: Mounting installer disk image." >> ${logfile}
		/usr/bin/hdiutil attach /tmp/AdobeAIR.dmg -nobrowse -quiet
		/bin/echo "`date`: Installing..." >> ${logfile}
		/Volumes/Adobe\ AIR/Adobe\ AIR\ Installer.app/Contents/MacOS/Adobe\ AIR\ Installer -silent
		/bin/sleep 10
		/bin/echo "`date`: Unmounting installer disk image." >> ${logfile}
		/usr/bin/hdiutil detach $(/bin/df | /usr/bin/grep Adobe\ AIR | awk '{print $1}') -quiet
		/bin/sleep 10
		/bin/echo "`date`: Deleting disk image." >> ${logfile}
		/bin/rm /tmp/${dmgfile}
		
		#double check to see if the new version got updated
		newlyinstalledver=`/usr/bin/defaults read /Applications/Utilities/Adobe\ AIR\ Application\ Installer.app/Contents/Info CFBundleShortVersionString`
        if [ "${latestver}" = "${newlyinstalledver}" ]; then
            /bin/echo "`date`: SUCCESS: Adobe AIR has been updated to version ${newlyinstalledver}" >> ${logfile}
	   # /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType hud -title "Adobe AIR Updated" -description "Adobe AIR has been updated." &
        else
            /bin/echo "`date`: ERROR: Adobe AIR update unsuccessful, version remains at ${currentinstalledver}." >> ${logfile}
            /bin/echo "--" >> ${logfile}
			exit 1
		fi
    
	# If Adobe AIR is up to date already, just log it and exit.       
	else
		/bin/echo "`date`: Adobe AIR is already up to date, running ${currentinstalledver}." >> ${logfile}
        /bin/echo "--" >> ${logfile}
	fi	
else
	/bin/echo "`date`: ERROR: This script is for Intel Macs only." >> ${logfile}
fi

exit 0