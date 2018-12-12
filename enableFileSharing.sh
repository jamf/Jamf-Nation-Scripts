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
#	enableFileSharing.sh -- Enables or Disables Personal File Sharing on Mac OS X Clients.
#
# SYNOPSIS
#	sudo enableFileSharing.sh
#	sudo enableFileSharing.sh <mountPoint> <computerName> <currentUsername> <enableFileSharing>
#
# 	If there is a hardcoded value specified for <enableFileSharing> in the script, 
#	or if the parameter is not passed by The Casper Suite, the hardcoded value in the script will 
#	be used.
#
#	The data that is specified for the <enableFileSharing> parameter should be specified in one of
#	the following formats:
#
#		"t" "T" "true" "True" "TRUE"
#		"f" "F" "false" "False" "FALSE"
#		"y" "Y" "yes" "Yes "YES"
#		"n" "N" "no" "No" "NO"
#
# DESCRIPTION
#	This script enables or disables the Personal File Sharing preference on Mac OS X 10.3 or later.
#	It can be used with a hardcoded value in the script, or read in as a parameter.
#	Since the Casper Suite defines the first three parameters as (1) Mount Point, (2) Computer
#	Name and (3) username, we are using the fourth parameter ($4) as the passable parameter to
#	acquire the status of <enableFileSharing>.  In addition, the fourth parameter is utilized to set 
#	the enableFileSharing parameter.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Nick Amundsen on August 6 2008
#
#	Version: 2.0
#
#	- Created by Brock Walters on November 13 2008
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

# HARDCODED VALUE FOR "enableFileSharing" IS SET HERE
enableFileSharing=""

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "enableFileSharing"
if [ "$4" != "" ] && [ "$enableFileSharing" == "" ]; then
	enableFileSharing=$4
fi

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

if [ "$enableFileSharing" == "" ]; then
	echo "Error:  The parameter 'enableFileSharing' is blank.  Please specify a value."
	exit 1
fi

osx=$(/usr/bin/sw_vers -productVersion)
ref=$(/usr/bin/sw_vers -productVersion | /usr/bin/awk '{print substr($1,4,2)}')

if [[ "$ref" -lt 5 ]]
then
	case $enableFileSharing in 
	"t" | "T" |"true" | "True" | "TRUE" | "y" | "Y" | "yes" | "Yes" | "YES")
			echo "Enabling File Sharing for OS $osx ..."
			### Write out AFPSERVER key to hostconfig
			/usr/bin/sed 's/AFPSERVER=-NO-/AFPSERVER=-YES-/g' /private/etc/hostconfig > /tmp/hostconfig

			### Replace old hostconfig with new
			/bin/mv /private/etc/hostconfig /private/etc/hostconfig.bac
			/bin/mv /tmp/hostconfig /private/etc/hostconfig
			/usr/sbin/chown root:admin /private/etc/hostconfig
			/bin/chmod 644 /private/etc/hostconfig

			### Start AFP
			echo "Starting Personal File Sharing..."
			/usr/sbin/AppleFileServer
			;;
	"f" | "F" | "false" | "False" | "FALSE" | "n" | "N" | "no" | "No" | "NO")
			echo "Disabling File Sharing for OS $osx ..."
			### Write out AFPSERVER key to hostconfig
			/usr/bin/sed 's/AFPSERVER=-YES-/AFPSERVER=-NO-/g' /private/etc/hostconfig > /tmp/hostconfig

			### Replace old hostconfig with new
			/bin/mv /private/etc/hostconfig /private/etc/hostconfig.bac
			/bin/mv /tmp/hostconfig /private/etc/hostconfig
			/usr/sbin/chown root:admin /private/etc/hostconfig
			/bin/chmod 644 /private/etc/hostconfig

			### Kill AFP
			echo "Disabling Personal File Sharing..."
			/usr/bin/killall AppleFileServer
			;;
	esac
else
	case $enableFileSharing in
	"t" | "T" |"true" | "True" | "TRUE" | "y" | "Y" | "yes" | "Yes" | "YES")
			echo "Enabling File Sharing for OS $osx ..."
			/bin/launchctl load -w /System/Library/LaunchDaemons/com.apple.AppleFileServer.plist
			;;
	"f" | "F" | "false" | "False" | "FALSE" | "n" | "N" | "no" | "No" | "NO")
			echo "Disabling File Sharing for OS $osx ..."
			/bin/launchctl unload -w /System/Library/LaunchDaemons/com.apple.AppleFileServer.plist
			;;
	esac
fi