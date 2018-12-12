#!/bin/bash

##########################################################################################
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
##########################################################################################
#
# SUPPORT FOR THIS PROGRAM
#
#       This program is distributed "as is" by JAMF.
#
#       Please reference our SLA for information regarding support of this application:
#
#               http://www.jamfsoftware.com/support/resource-kit-sla
#
##########################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#
#	enable.lpadmin.sh - enable or disable a standard user's ability to add printers
#
# SYNOPSIS
#
#	sudo sh enable.lpadmin.sh
#	sudo sh enable.lpadmin.sh <mountPoint> <computerName> <username> <lock>
#
# DESCRIPTION
#
#	This script enables or disables the System Preferences authorization for standard
#	users to add printers as reflected in the Printers System Preference pane. It has
#	been designed to function on Mac OS X 10.5.7 (when the restriction first appeared)
#	& later. The disabled or enabled state is set according to the value specified in
#	the "$lock" variable.
#
#	The Casper Suite defines the first three shell parameters as (1) Mount Point, (2)
#	Computer Name and (3) username. The value for "$lock" can be set to "enable" or
#	"disable" in 1 of 3 ways:
#
#		- by populating the parameter 4 field with "enable" or "disable" when using the
#		script as the payload in a Jamf Pro policy
# 		- by passing it as argument 4 of the command to run the script (see SYNOPSIS above
#		for syntax)
# 		- by hard-coding the value into the script below
#
##########################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	Created by Cameron Evjen June 11 2009
#	Modified by Nick Amundsen June 11 2009
#	Modified by Nick Amundsen August 4th 2010 - support for directory service accounts
#	Modified by Brock Walters Oct 19 2016 - support for macOS
#
##########################################################################################

# SET HARDCODED VALUES HERE

targetVolume=""
lock=""

##########################################################################################
# 
# DO NOT MODIFY BELOW THIS LINE 
#
##########################################################################################

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 1 AND, IF SO, ASSIGN TO "targetVolume"

targetVolume="${targetVolume:-$1}"

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "lock"

lock="${lock:-$4}"

# OS X version

osxv=$(/usr/bin/defaults read /System/Library/CoreServices/SystemVersion ProductVersion | /usr/bin/awk -F . '{print $2 $3}')
if echo "${#osxv}" | /usr/bin/grep -q 2
then
	osxv=$(echo "$osxv 0" | /usr/bin/sed 's/ //g')
fi

# set printer group

if [ "$osxv" -gt 56 ]
then
	case "$lock" in

enable | ENABLE | Enable )

>&2 echo "
Enabling standard users to add printers...
Adding everyone group to the Printer Administrators (lpadmin) group...
"
/usr/sbin/dseditgroup -o edit -n /Local/Default -a everyone -t group lpadmin
;;

disable | DISABLE | Disable )

>&2 echo "
Disabling standard users for adding printers...
Removing everyone group from the Printer Administrators (lpadmin) group...
"
/usr/sbin/dseditgroup -o edit -n /Local/Default -d everyone -t group lpadmin
;;

* )

>&2 echo "
Error: the \"lock\" parameter input was either invalid or blank.
Specify the parameter value as either \"enable\" or \"disable\".
"
;;

	esac
else
	>&2 echo "This computer is not running OS X 10.5.7 or higher. The setting is not applicable."
fi