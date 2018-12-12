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
#	enableARD.sh -- Enable ARD and Configure Remote Management Settings
#
# SYNOPSIS
#	sudo enableARD.sh
#	sudo enableARD.sh <mountPoint> <computerName> <currentUsername> <targetUsername>
#
# 	If the $targetUsername parameter is specified (parameter 4), this is the account that will be 
# 	granted access to ARD.
#
# 	If no parameter is specified for parameter 4, the hardcoded value in the script will be used.
#
# DESCRIPTION
#	This script enables and configures remote management settings for a user.  There are a number
#	of options that the script is capable of configuring, which should be specified in the privs
#	string.  Please see the kickstart man page for more information.
#
#	The following options are available in the kickstart application:
#
#		-DeleteFiles
#		-ControlObserve
#		-TextMessages
#		-ShowObserve
#		-OpenQuitApps
#		-GenerateReports
#		-RestartShutDown
#		-SendFiles
#		-ChangeSettings
#		-ObserveOnly
#		-mask
#
#	ARD access is granted and priviliges  are assigned to an individual account on computers running 
#	Mac OS X 10.3 and later. It can be used with a hardcoded value in the script, or read in as a 
#	parameter.  Since the Casper Suite defines the first three parameters as (1) Mount Point, 
#	(2) Computer Name and (3) username, we are using the forth parameter ($4) as the passable 
#	parameter.  We do not use $3 since it may not match up to the username that we want to grant
#	access for.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.1
#
#	- Created by Tedd Herman on August 5th, 2008
#	- Modified by Nick Amundsen on August 5th, 2008
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################


# HARDCODED VALUE FOR "USERNAME" IS SET HERE
targetUsername=""


# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "USERNAME"
if [ "$4" != "" ] && [ "$targetUsername" == "" ];then
    targetUsername=$4
fi

# DEFINE WHICH PRIVILEGES WILL BE SET FOR THE SPECIFIED USER
privs="-DeleteFiles -ControlObserve -TextMessages -OpenQuitApps -GenerateReports -RestartShutDown -SendFiles -ChangeSettings"

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

if [ "$targetUsername" != "" ]; then
	echo "Enabling Apple Remote Desktop Agent..."
	/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -allowAccessFor -specifiedUsers
	echo "Setting Remote Management Privileges for User: $targetUsername ..."
	/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -access -on -privs $privs -users $targetUsername
else
	echo "Error:  The parameter 'targetUsername' is blank.  Please specify a user."
fi