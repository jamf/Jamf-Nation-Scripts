#!/bin/bash

####################################################################################################
#
# Copyright  2015, JAMF Software, LLC.  All rights reserved.
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
# HISTORY
#
# Version 1.0 by Brock Walters July 14 2015
# Version 1.1 by Brock Walters January 22 2016
# Version 2.0 by Brock Walters September 8 2016 - modified for macOS 10.12 & older OS X versions
#
####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#   gatekeep.sh -- Configure the Gatekeeper settings
#
# SYNOPSIS
#   sudo gatekeep.sh
#   sudo gatekeep.sh <mountPoint> <computerName> <currentUsername> <gatekeeper>
#
# DESCRIPTION
#   
# The Gatekeeper settings are located on the General tab of the Security & Privacy System
# Preferences Preference Pane. Use this script to set the radio buttons as desired.
#
# The script creates a copy of the System Policy database named "/private/var/db/SystemPolicy.bak"
# Default System Policy settings can be restored by deleting "/private/var/db/SystemPolicy" then
# copying "/private/var/db/.SystemPolicy-default" to "/private/var/db/SystemPolicy" Computers
# should be restarted after restoring older versions of the System Policy database.
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
# 1 of the 3 exact text strings below associated with the Gatekeeper features must be used as
# the variable input value:
#
#     "App Store"
#     "App Store and identified developers"
#     "Anywhere"
# 
# Input the value by:
#
# - copying it into the parameter 4 field when using the script as the payload in a Jamf Pro policy
# - passing it as argument 4 of the command to run the script (see SYNOPSIS above for syntax)
# - hard-coding the value into the script below
#
# If hard-coding the "gatekeeper" variable copy & paste the string between the double quotes
# following the = sign, e.g., gatekeeper="App Store"
#
####################################################################################################

gatekeeper=""

####################################################################################################
#
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

# check for root user execution

if [ "$EUID" -ne 0 ]
then
    >&2 /bin/echo "error: this script must be excuted by the root user!"$'\a'
    exit
fi

# close System Preferences if running & backup SystemPolicy db

/usr/bin/pkill "System Preferences"

if [ ! -f /private/var/db/SystemPolicy.bak ]
then
    /bin/cp /private/var/db/SystemPolicy{,.bak}
fi

# populate parameter 4 & set gatekeeper

gatekeeper="${gatekeeper:-$4}"

masterenable(){
if /usr/sbin/spctl --status | grep -q "assessments disabled"
then
    /usr/sbin/spctl --master-enable
fi
}

if [ "$gatekeeper" != "" ]
then
	while true
	do
		case "$gatekeeper" in
		"App Store" )
			masterenable
			/usr/sbin/spctl --disable --rule {7,6}
			echo "setting Gatekeeper to App Store"
			exit
			;;
		"App Store and identified developers" )
			masterenable
			/usr/sbin/spctl --enable --rule {8,7,6,5,4}
			echo "setting Gatekeeper to App Store and identified developers"
			exit
			;;
		"Anywhere" )
			/usr/sbin/spctl --master-disable
			echo "disabling Gatekeeper"
			exit
			;;
		* )	
			>&2 /bin/echo "error: the gatekeeper variable is not populated correctly."$'\a'
			exit
			;;
		esac
	done
else
	>&2 /bin/echo "error: the gatekeeper variable is not populated."$'\a'
fi
