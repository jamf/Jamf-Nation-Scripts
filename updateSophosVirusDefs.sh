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
#	updateSophosVirusDefs.sh -- Update virus definitions for Sophos AntiVirus
#
# SYNOPSIS
#	sudo updateSophosVirusDefs.sh
#	sudo updateSophosVirusDefs.sh <mountPoint> <computerName> <currentUsername> <defsDate> <defsVersion>
#
# DESCRIPTION
#	This script will download the latest virus definitions for Sophos AntiVirus for mac to ensure that
#	the latest definition set is being used whenever a Sophos scan is run.
#
#	Please note that this script was created using the latest version of Sophos AV available at the
#	time of the script creation (4.9).  Compatibility with versions of Sophos AV created prior to 
#	and post 4.9 is unknown at this time.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Nick Amundsen on December 19, 2008
#
####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

## CHECK TO SEE IF SOPHOSUPDATE EXISTS
if [ -f "/usr/bin/sophosupdate" ]; then
	
	if [ -f "/Sophos Anti-Virus/ESOSX/Sophos Anti-Virus.mpkg/Contents/Packages/SophosAU.mpkg/Contents/Resources/com.sophos.sau.plist" ]; then
		updateServer=`/usr/bin/defaults read /Sophos\ Anti-Virus/ESOSX/Sophos\ Anti-Virus.mpkg/Contents/Packages/SophosAU.mpkg/Contents/Resources/com.sophos.sau PrimaryServerURL`
		echo "Primary Update Server: $updateServer"
	fi

	versionBefore=`/usr/bin/sweep -v | grep "Virus data version" | awk '{print $5}'`
	echo "Currently installed definition file: $versionBefore"

	dateBefore=`/usr/bin/sweep -v | grep "System" | awk '{print $6,$7,$8}'`
	echo "Currently installed definition date: $dateBefore"

	echo "Updating Sophos Virus definitions..."
	/usr/bin/sophosupdate

	versionAfter=`/usr/bin/sweep -v | grep "Virus data version" | awk '{print $5}'`
	dateAfter=`/usr/bin/sweep -v | grep "System" | awk '{print $6,$7,$8}'`

	updateStatus=$(sophosupdate 2>&1)

	if  echo "$updateStatus" | grep -q "denied" ; then
		echo "Error:  Update Failed.  Please enter a different username or password in the Sophos Update Manager preferences."
		echo "Definition file version after update: $versionAfter"
		echo "Definition file date after update: $dateAfter"
		exit 1
	fi

else
	echo "Error:  The sophosupdate command line tool does not appear to be installed at: /usr/bin/sophosupdate.  The update will be aborted."
	exit 1
fi

exit 0