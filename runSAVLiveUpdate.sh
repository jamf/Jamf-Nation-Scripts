#!/bin/sh
####################################################################################################
#
# Copyright (c) 2010, JAMF Software, LLC.  All rights reserved.
#
#       Redistribution and use in source and binary forms, with or without
#       modification, are permitted provided that the following conditions are met:
#               * Redistributions of source code must retain the above copyright
#                 notice, this list of conditions and the following disclaimer.
#               * Redistributions in binary form must reproduce the above copyright
#                 notice, this list of conditions and the following disclaimer in the
#                 documentation and/or other materials provided with the distribution.
#               * Neither the name of the JAMF Software, LLC nor the
#                 names of its contributors may be used to endorse or promote products
#                 derived from this software without specific prior written permission.
#
#       THIS SOFTWARE IS PROVIDED BY JAMF SOFTWARE, LLC "AS IS" AND ANY
#       EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#       WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#       DISCLAIMED. IN NO EVENT SHALL JAMF SOFTWARE, LLC BE LIABLE FOR ANY
#       DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#       (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#       LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#       ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#       SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
####################################################################################################
#
# SUPPORT FOR THIS PROGRAM
#
#       This program is distributed "as is" by JAMF Software, LLC's Resource Kit team. For more
#       information or support for the Resource Kit, please utilize the following resources:
#
#               http://list.jamfsoftware.com/mailman/listinfo/resourcekit
#
#               http://www.jamfsoftware.com/support/resource-kit
#
#       Please reference our SLA for information regarding support of this application:
#
#               http://www.jamfsoftware.com/support/resource-kit-sla
#
####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#	runSAVLiveUpdate.sh -- Run Symantec LiveUpdate.
#
# SYNOPSIS
#	sudo runSAVLiveUpdate.sh
#	sudo runSAVLiveUpdate.sh <mountPoint> <computerName> <currentUsername>
#
# DESCRIPTION
#	This script will run the Symantec LiveUpdate application in the background which will silently
#	download and install the latest virus definitions available from Symantec.
#
#	This script expects Symantec LiveUpdate to be installed at:
#
#		/Applications/Symantec Solutions/LiveUpdate.app
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.1
#
#	- Created by Nick Amundsen on August 6th, 2008
#	- Updated by Nick Amundsen on November 22nd, 2010
#		- Fixed an issue that prevents LiveUpdate from running when the machine is at the loginwindow
#		  and improved error logging.
#
####################################################################################################
# 
# LOGGING FUNCTION
#
####################################################################################################
logFile="/private/var/log/runSAVLiveUpdate.log"

log () {
	echo $1
	echo $(date "+%Y-%m-%d %H:%M:%S: ") $1 >> $logFile	
}

####################################################################################################
# 
# SCRIPT CONTENTS
#
####################################################################################################

if [ -f "/Applications/Symantec Solutions/LiveUpdate.app/Contents/MacOS/LiveUpdate" ]; then	
	checkForLoggedInUsers=`who | grep console`
	if [ "$checkForLoggedInUsers" == "" ]; then
		#Nobody is logged in - Launch LiveUpdate with a LaunchDaemon
		log "Running LiveUpdate using a LaunchDaemon..."
		log "	Creating LaunchDaemon..."
		/usr/bin/defaults write '/Library/LaunchDaemons/com.jamfsoftware.runSAVLiveUpdate' Label -string 'com.jamfsoftware.runSAVLiveUpdate'
		/usr/bin/defaults write '/Library/LaunchDaemons/com.jamfsoftware.runSAVLiveUpdate' LaunchOnlyOnce -bool 'true'
		/usr/bin/defaults write '/Library/LaunchDaemons/com.jamfsoftware.runSAVLiveUpdate' ProgramArguments -array '/Applications/Symantec Solutions/LiveUpdate.app/Contents/MacOS/LiveUpdate'
		/usr/bin/defaults write '/Library/LaunchDaemons/com.jamfsoftware.runSAVLiveUpdate' ProgramArguments -array-add '-update'
		/usr/bin/defaults write '/Library/LaunchDaemons/com.jamfsoftware.runSAVLiveUpdate' ProgramArguments -array-add 'LUal'
		/usr/bin/defaults write '/Library/LaunchDaemons/com.jamfsoftware.runSAVLiveUpdate' ProgramArguments -array-add '-liveupdatequiet'
		/usr/bin/defaults write '/Library/LaunchDaemons/com.jamfsoftware.runSAVLiveUpdate' ProgramArguments -array-add 'YES'
		/usr/bin/defaults write '/Library/LaunchDaemons/com.jamfsoftware.runSAVLiveUpdate' ProgramArguments -array-add '-liveupdateautoquit'
		/usr/bin/defaults write '/Library/LaunchDaemons/com.jamfsoftware.runSAVLiveUpdate' ProgramArguments -array-add 'YES'
		/usr/bin/defaults write '/Library/LaunchDaemons/com.jamfsoftware.runSAVLiveUpdate' LimitLoadToSessionType -array 'Aqua'
		/usr/bin/defaults write '/Library/LaunchDaemons/com.jamfsoftware.runSAVLiveUpdate' LimitLoadToSessionType -array-add 'LoginWindow'
		/usr/bin/defaults write '/Library/LaunchDaemons/com.jamfsoftware.runSAVLiveUpdate' RunAtLoad -bool 'true'
		/usr/bin/defaults write '/Library/LaunchDaemons/com.jamfsoftware.runSAVLiveUpdate' UserName -string 'root'
		chown root:wheel /Library/LaunchDaemons/com.jamfsoftware.runSAVLiveUpdate.plist
		chmod 644 /Library/LaunchDaemons/com.jamfsoftware.runSAVLiveUpdate.plist
		log "	Loading LaunchDaemon..."
		/bin/launchctl load -S Aqua -S LoginWindow /Library/LaunchDaemons/com.jamfsoftware.runSAVLiveUpdate.plist
		if [ $? == 0 ]; then
			log "Loaded LiveUpdate using a LaunchDaemon."
		else
			log "There was an error loading the LaunchDaemon. Exit Code: $?"
		fi
		#Move the LaunchDaemon to /private/tmp so it does not get called again
		/bin/mv /Library/LaunchDaemons/com.jamfsoftware.runSAVLiveUpdate.plist /private/tmp/com.jamfsoftware.runSAVLiveUpdate.plist
	else
		#Someone is logged in - Launch LiveUpdate providing the path to the app
		log "Running LiveUpdate..."
		/Applications/Symantec\ Solutions/LiveUpdate.app/Contents/MacOS/LiveUpdate -update LUal -liveupdatequiet YES -liveupdateautoquit YES
		if [ $? == 0 ]; then
			log "Finished running LiveUpdate."
		else
			log "There was an error running LiveUpdate. Exit Code: $?"
		fi
	fi
else	
	log "Error:  Symantec LiveUpdate was not found on this machine."
	exit 1
fi