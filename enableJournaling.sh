#!/bin/sh
####################################################################################################
#
# Copyright (c) 2012, JAMF Software, LLC.  All rights reserved.
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
#	enableJournaling.sh -- Enable journaling on an HFS+ volume.
#
# SYNOPSIS
#	sudo enableJournaling.sh
#	sudo enableJournaling.sh <mountPoint> <computerName> <currentUsername>
#
# 	If the $mountPoint parameter is passed from The Casper Suite, this is the volume on which
#	journaliing will be enabled.
#
#	If the mountPoint parameter is hardcoded in this script, it will override any parameter that 
#	has been passed from The Casper Suite.
#
# DESCRIPTION
#	This script enables the journaling feature on the specified HFS+ volume.  Journaling can help
#	protect a drive against corruption in the event of power loss or power failure and can also
#	expedite the repair process if a bad sector is found.  This script was designed to take
#	advantage of The Casper Suite automatically passing the <mountPoint> parameter.
#	
#	For further description of file system journaling, see:
#
#		http://support.apple.com/kb/HT2355
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.1
#
#	- Created by Nick Amundsen on August 6th, 2008
#	- Updated by Nick Amundsen on May 14th, 2012
#		- Fixed error in assigning mountPoint via parameters
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################


# HARDCODED VALUE FOR "mountPoint" IS SET HERE
mountPoint=""


# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 1 AND, IF SO, ASSIGN TO "mountPoint"
if [ "$1" != "" ] && [ "$mountPoint" == "" ];then
    mountPoint=$1
fi



####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

if [ "$mountPoint" != "" ]; then
	echo "Enabling journaling for the device at $mountPoint..."
	/usr/sbin/diskutil enableJournal $mountPoint
else
	echo "Error:  The parameter 'mountPoint' is blank.  Please specify a mount point."
fi