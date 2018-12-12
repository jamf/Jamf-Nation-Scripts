#!/bin/sh
####################################################################################################
#
# Copyright (c) 2017, JAMF Software, LLC.  All rights reserved.
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
#	enableFilewall.sh -- Enables or Disables the firewall on Mac OS X Clients.
#
# SYNOPSIS
#	sudo enableFirewall.sh
#	sudo enableFirewall.sh <mountPoint> <computerName> <currentUsername> <enableFirewall>
#
# 	If there is a hardcoded value specified for <enableFirewall> in the script, 
#	or if the parameter is not passed by The Casper Suite, the hardcoded value in the script will 
#	be used.
#
#	The data that is specified for the <enableFirewall> parameter should be specified in one of
#	the following formats:
#
#		"TRUE"
#		"FALSE"
#		"YES"
#		"NO"
#
# DESCRIPTION
#	This script enables or disables the firewall on Mac OS X 10.3 or later.
#	It can be used with a hardcoded value in the script, or read in as a parameter.
#	Since the Casper Suite defines the first three parameters as (1) Mount Point, (2) Computer
#	Name and (3) username, we are using the fourth parameter ($4) as the passable parameter to
#	acquire the status of <enableFirewall>.  In addition, the fourth parameter is utilized to set 
#	the enableFirewall parameter.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.2
#
#	- Created by Nick Amundsen on August 6th, 2008
#	- Updated by Nick Amundsen on January 21, 2010
#	- Updated by Brandon Wenger on November 27th, 2017
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################


# HARDCODED VALUE FOR "enableFirewall" IS SET HERE
enableFirewall=""


# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "enableFirewall"
if [ "$4" != "" ] && [ "$enableFirewall" == "" ]; then
	enableFirewall=$4
fi


####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

if [ "$enableFirewall" == "" ]; then
	echo "Error:  The parameter 'enableFirewall' is blank.  Please specify a value."
	exit 1
fi

OS=`/usr/bin/defaults read /System/Library/CoreServices/SystemVersion ProductVersion | awk '{print substr($1,1,5)}'`

if [[ "$OS" == "10.4" ]]
then
	case $enableFirewall in "true" | "TRUE" | "yes" | "YES")
			echo "Enabling Firewall for OS $OS ..."
			/usr/bin/defaults write /Library/Preferences/com.apple.sharing.firewall state -bool YES
			/usr/libexec/FirewallTool;;
	"false" | "FALSE" | "no" | "NO")
			echo "Disabling Firewall for OS $OS ..."
			/usr/bin/defaults write /Library/Preferences/com.apple.sharing.firewall state -bool NO
			/usr/libexec/FirewallTool;;
	esac
fi

if [[ "$OS" != "10.4" ]]
then
	case $enableFirewall in "true" | "TRUE" | "yes" | "YES")
			echo "Enabling Firewall for OS $OS ..."
			/usr/bin/defaults write /Library/Preferences/com.apple.alf globalstate -int 1
			/bin/launchctl unload /System/Library/LaunchDaemons/com.apple.alf.agent.plist
			/bin/launchctl unload /System/Library/LaunchAgents/com.apple.alf.useragent.plist
			/bin/launchctl load /System/Library/LaunchDaemons/com.apple.alf.agent.plist
			/bin/launchctl load /System/Library/LaunchAgents/com.apple.alf.useragent.plist;;
	"false" | "FALSE" | "no" | "NO")
			echo "Disabling Firewall for OS $OS ..."
			/usr/bin/defaults write /Library/Preferences/com.apple.alf globalstate -int 0
			/bin/launchctl unload /System/Library/LaunchDaemons/com.apple.alf.agent.plist
			/bin/launchctl unload /System/Library/LaunchAgents/com.apple.alf.useragent.plist
			/bin/launchctl load /System/Library/LaunchDaemons/com.apple.alf.agent.plist
			/bin/launchctl load /System/Library/LaunchAgents/com.apple.alf.useragent.plist;;
	esac
fi

exit 0;