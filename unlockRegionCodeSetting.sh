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
#	unlockRegionCodeSetting.sh -- Unlock the DVD region code setting
#
# SYNOPSIS
#	sudo unlockRegionCodeSetting.sh
#	sudo unlockRegionCodeSetting.sh <mountPoint> <computerName> <username> <locked>
#
# 	If the $locked parameter is specified as true or false (in parameter 4), this is the setting
#	that will be set.
#
# 	If no parameter is specified for parameter 4, the hardcoded value in the script will be used.
#
# DESCRIPTION
#	This script unlocks or locks the system preference authorization to allow or disallow users to
#	set the DVD region code, as reflected in the DVD player application.  It has been designed to 
#	function on Mac OS X 10.4 and higher with DVD Player.app 1.0 and higher.
#
#	The locked/unlock value will be set according to the value specified in the paramter $locked.  
#	It can be used with a hardcoded value in the script, or read in as a parameter.  Since the 
#	Casper Suite defines the first three parameters as (1) Mount Point, (2) Computer Name and 
#	(3) username, we are using the forth parameter ($4) as the passable parameter.  If no parameter
#	is passed, then the hardcoded value will be used.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Cameron Evjen on June 5th, 2009
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################


# HARDCODED VALUE FOR "locked" IS SET HERE
targetVolume=""
locked="false"

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 3 AND, IF SO, ASSIGN TO "targetVolume"
if [ "$1" != "" ] && [ "$targetVolume" == "" ]; then
    targetVolume=$1
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "locked"
if [ "$4" != "" ] && [ "$locked" == "" ]; then
    locked=$4
fi

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

OS=`/usr/bin/defaults read /System/Library/CoreServices/SystemVersion ProductVersion | awk '{print substr($1,1,4)}'`

case $locked in "false" | "FALSE" | "no" | "NO")
	if [[ "$OS" < "10.5" ]]; then
		echo "Unlocking region code setting using OS $OS..."
		if [[ -f "/Library/Receipts/AdditionalEssentials.pkg/Contents/Resources/PlistBuddy" ]]; then
			/Library/Receipts/AdditionalEssentials.pkg/Contents/Resources/PlistBuddy -c "Set :rights:system.device.dvd.setregion.initial:class allow" "$targetVolume/private/etc/authorization"
		else
			echo "PlistBuddy command not found.  The DVD region code cannot be unlocked.  Please ensure that PlistBuddy is installed at /Library/Receipts/AdditionalEssentials.pkg/Contents/Resources/PlistBuddy."
		fi
	else
		echo "Unlocking region code setting using OS $OS..."
		if [[ -f "/usr/libexec/PlistBuddy" ]]; then
			/usr/libexec/PlistBuddy -c "Set :rights:system.device.dvd.setregion.initial:class allow" "$targetVolume/private/etc/authorization"
		else
			echo "PlistBuddy command not found.  The DVD region code cannot be unlocked.  Please ensure that PlistBuddy is installed at /usr/libexec/PlistBuddy."
		fi	
	fi;;
	"true" | "TRUE" | "yes" | "YES")
	if [[ "$OS" < "10.5" ]]; then
		echo "Locking region code setting using OS $OS..."
		if [[ -f "/Library/Receipts/AdditionalEssentials.pkg/Contents/Resources/PlistBuddy" ]]; then
			/Library/Receipts/AdditionalEssentials.pkg/Contents/Resources/PlistBuddy -c "Set :rights:system.device.dvd.setregion.initial:class user" "$targetVolume/private/etc/authorization"
		else
			echo "PlistBuddy command not found.  The DVD region code cannot be locked.  Please ensure that PlistBuddy is installed at /Library/Receipts/AdditionalEssentials.pkg/Contents/Resources/PlistBuddy."
		fi
	else
		echo "Locking region code setting using OS $OS..."
		if [[ -f "/usr/libexec/PlistBuddy" ]]; then
			/usr/libexec/PlistBuddy -c "Set :rights:system.device.dvd.setregion.initial:class user" "$targetVolume/private/etc/authorization"
		else
			echo "PlistBuddy command not found.  The DVD region code cannot be locked.  Please ensure that PlistBuddy is installed at /usr/libexec/PlistBuddy."
		fi	
	fi;;
	*)
	echo "Error:  The parameter 'locked' is blank or is set to an invalid value.  Please specify a valid value such as YES, yes, TRUE, true, NO, no, FALSE, false."
esac