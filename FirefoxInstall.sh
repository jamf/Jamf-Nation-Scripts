#!/bin/sh
#####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#	FirefoxInstall.sh -- Installs or updates Firefox
#
# SYNOPSIS
#	sudo FirefoxInstall.sh
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Joe Farage, 18.03.2015
#
####################################################################################################
# Script to download and install Firefox.
# Only works on Intel systems.
#
# choose language (en-US, fr, de)
lang=""
# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 1 AND, IF SO, ASSIGN TO "lang"
if [ "$4" != "" ] && [ "$lang" == "" ]; then
	lang=$4
else 
	lang="en-US"
fi

dmgfile="FF.dmg"
logfile="/Library/Logs/FirefoxInstallScript.log"

# Are we running on Intel?
if [ '`/usr/bin/uname -p`'="i386" -o '`/usr/bin/uname -p`'="x86_64" ]; then
	## Get OS version and adjust for use with the URL string
	OSvers_URL=$( sw_vers -productVersion | sed 's/[.]/_/g' )

	## Set the User Agent string for use with curl
	userAgent="Mozilla/5.0 (Macintosh; Intel Mac OS X ${OSvers_URL}) AppleWebKit/535.6.2 (KHTML, like Gecko) Version/5.2 Safari/535.6.2"

	# Get the latest version of Reader available from Firefox page.
	latestver=`/usr/bin/curl -s -A "$userAgent" https://www.mozilla.org/${lang}/firefox/new/ | grep 'data-latest-firefox' | sed -e 's/.* data-latest-firefox="\(.*\)".*/\1/' -e 's/\"//' | /usr/bin/awk '{print $1}'`
	echo "Latest Version is: $latestver"

	# Get the version number of the currently-installed FF, if any.
	if [ -e "/Applications/Firefox.app" ]; then
		currentinstalledver=`/usr/bin/defaults read /Applications/Firefox.app/Contents/Info CFBundleShortVersionString`
		echo "Current installed version is: $currentinstalledver"
		if [ ${latestver} = ${currentinstalledver} ]; then
			echo "Firefox is current. Exiting"
			exit 0
		fi
	else
		currentinstalledver="none"
		echo "Firefox is not installed"
	fi

	url="https://download-installer.cdn.mozilla.net/pub/firefox/releases/${latestver}/mac/${lang}/Firefox%20${latestver}.dmg"
	
	echo "Latest version of the URL is: $url"
	echo "`date`: Download URL: $url" >> ${logfile}

	# Compare the two versions, if they are different or Firefox is not present then download and install the new version.
	if [ "${currentinstalledver}" != "${latestver}" ]; then
        /bin/echo "`date`: Current Firefox version: ${currentinstalledver}" >> ${logfile}
		/bin/echo "`date`: Available Firefox version: ${latestver}" >> ${logfile}
		/bin/echo "`date`: Downloading newer version." >> ${logfile}
		/usr/bin/curl -s -o /tmp/${dmgfile} ${url}
		/bin/echo "`date`: Mounting installer disk image." >> ${logfile}
		/usr/bin/hdiutil attach /tmp/${dmgfile} -nobrowse -quiet
		/bin/echo "`date`: Installing..." >> ${logfile}
		ditto -rsrc "/Volumes/Firefox/Firefox.app" "/Applications/Firefox.app"
		
		/bin/sleep 10
		/bin/echo "`date`: Unmounting installer disk image." >> ${logfile}
		/usr/bin/hdiutil detach $(/bin/df | /usr/bin/grep Firefox | awk '{print $1}') -quiet
		/bin/sleep 10
		/bin/echo "`date`: Deleting disk image." >> ${logfile}
		/bin/rm /tmp/${dmgfile}
		
		#double check to see if the new version got updated
		newlyinstalledver=`/usr/bin/defaults read /Applications/Firefox.app/Contents/Info CFBundleShortVersionString`
        if [ "${latestver}" = "${newlyinstalledver}" ]; then
            /bin/echo "`date`: SUCCESS: Firefox has been updated to version ${newlyinstalledver}" >> ${logfile}
	   # /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType hud -title "Firefox Installed" -description "Firefox has been updated." &
        else
            /bin/echo "`date`: ERROR: Firefox update unsuccessful, version remains at ${currentinstalledver}." >> ${logfile}
            /bin/echo "--" >> ${logfile}
			exit 1
		fi
    
	# If Firefox is up to date already, just log it and exit.       
	else
		/bin/echo "`date`: Firefox is already up to date, running ${currentinstalledver}." >> ${logfile}
        /bin/echo "--" >> ${logfile}
	fi	
else
	/bin/echo "`date`: ERROR: This script is for Intel Macs only." >> ${logfile}
fi

exit 0