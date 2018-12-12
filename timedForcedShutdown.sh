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
#	timedForcedShutdown.sh -- This script will help to enforce a mandatory reboot or shut down.
#
# SYNOPSIS
#	sudo timedForcedShutdown.sh
#	sudo timedForcedShutdown.sh <mountPoint> <computerName> <currentUsername> <minutesN> 
#		<shutdownAction> <notificationMessage> <shutdownPhrase> <postponeAlert>
#
# DESCRIPTION
#	This script will help to enforce a mandatory reboot or shut down.
#
#	If no console user is logged in, the script will execute the command
#	stored in the $shutdownAction variable.
#
#	If a console user is logged in, a dialog is displayed informing the user
#	of the number of minutes until shutdown followed by a configurable
#	message stored in $notificationMessage.  The dialog contains two buttons.
#
#	Clicking the "Postpone" button will cancel shutdown/reboot.
#
#	Clicking the "Shut Down" button will execute the command
#	stored in the $shutdownAction variable.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Miles A. Leacy IV on May 20th, 2009
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

minutesN=2
# Number of minutes to count down before shutdown

shutdownAction="shutdown -r now"
# The default echo command above is for testing purposes.
# Change to "shutdown -r now" to reboot
# Change to "shutdown -h now" to shut down

notificationMessage="Please save any files you are working on.\n\n
Click Shut Down to shut down immediately\n
Click Postpone to postpone shut down until tomorrow evening."
# This message will appear in the initial dialog box following
# This computer is scheduled to $shutdownPhrase in $minutesN minutes.

shutdownPhrase="Shut Down"
# This variable should contain either "Shut Down" or "Restart"
# depending on the value of $shutdownAction.  This string will appear
# in the dialog and will determine the name of the button that causes
# $shutdownAction to be executed.

postponeAlert="Automatic shutdown has been postponed until tomorrow."

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "minutesN"
if [ "$4" != "" ] && [ "$minutesN" == "" ]; then
	minutesN=$4
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 5 AND, IF SO, ASSIGN TO "shutdownAction"
if [ "$5" != "" ] && [ "$shutdownAction" == "" ]; then
	shutdownAction=$5
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 6 AND, IF SO, ASSIGN TO "notificationMessage"
if [ "$6" != "" ] && [ "$notificationMessage" == "" ]; then
	notificationMessage=$6
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 7 AND, IF SO, ASSIGN TO "shutdownPhrase"
if [ "$7" != "" ] && [ "$shutdownPhrase" == "" ]; then
	shutdownPhrase=$7
fi


# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 8 AND, IF SO, ASSIGN TO "postponeAlert"
if [ "$8" != "" ] && [ "$postponeAlert" == "" ]; then
	postponeAlert=$8

fi

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

# If no user is logged in at the console, shut down immediately
consoleUser=`/usr/bin/w | grep console | awk '{print $1}'`
if test "$consoleUser"  == ""; then
	$shutdownAction
fi

function timedShutdown {
button=`/usr/bin/osascript << EOT
tell application "System Events"
	activate
	set shutdowndate to (current date) + "$minutesN" * minutes
	repeat
		set todaydate to current date
		set todayday to day of todaydate
		set todaytime to time of todaydate
		set todayyear to year of todaydate
		set shutdownday to day of shutdowndate
		set shutdownTime to time of shutdowndate
		set shutdownyear to year of shutdowndate
		set yearsleft to shutdownyear - todayyear
		set daysleft to shutdownday - todayday
		set timeleft to shutdownTime - todaytime
		set totaltimeleft to timeleft + {86400 * daysleft}
		set totaltotaltimeleft to totaltimeleft + {yearsleft * 31536000}
		set unroundedminutesleft to totaltotaltimeleft / 60
		set totalminutesleft to {round unroundedminutesleft}
		if totalminutesleft is less than 2 then
			set timeUnit to "minute"
		else
			set timeUnit to "minutes"
		end if
		if totaltotaltimeleft is less than or equal to 0 then
			exit repeat
		else
			display dialog "This computer is scheduled to " & "$shutdownPhrase" & " in " & totalminutesleft & " " & timeUnit & ". " & "$notificationMessage" & " " giving up after 60 buttons {"Postpone", "$shutdownPhrase"} default button "$shutdownPhrase"
			set choice to button returned of result
			if choice is not "" then
				exit repeat
			end if
		end if
	end repeat
	
end tell
return choice
EOT`
if test "$button" == "Postpone"; then
	`osascript << EOT
	tell application "System Events"
	activate
	display alert "$postponeAlert" as warning buttons "I understand" default button "I understand"
    end tell`
else
    $shutdownAction
    exit 0
fi
}

timedShutdown