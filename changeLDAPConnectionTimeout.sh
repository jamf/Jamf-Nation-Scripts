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
#	changeLDAPConnectionTimeout.sh -- Change the connection timeout to get to a Directory Server.
#
# SYNOPSIS
#	sudo changeLDAPConnectionTimeout.sh
#	sudo changeLDAPConnectionTimeout.sh <mountPoint> <computerName> <currentUsername> <timeout>
#
# 	If the $timeout parameter is specified (parameter 4), this is the timeout value that will be
#	set.  The timeout value should be specified as an integer in seconds.
#
# 	If no parameter is specified for parameter 4, the hardcoded value in the script will be used.
#
# DESCRIPTION
#	This script will modify the length of time that Directory Services will wait before an attempted
#	connection times out.  Modifying this value can be particularly useful in an environment with
#	mobile users that are bound to an LDAP server that is not accessible from the outside world.
#	The <timeout> value can be used with a hardcoded value in the script, or read in as a parameter.
#	Since the Casper Suite defines the first three parameters as (1) Mount Point, (2) Computer
#	Name and (3) username, we are using the fourth parameter ($4) as the passable parameter. 
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.1
#
#	- Created by Nick Amundsen on April 15th, 2008
#	- Modified by Nick Amundsen on August 1st, 2008
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################


# HARDCODED VALUE FOR "timeout" IS SET HERE
timeout=""


# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "timeout"
if [ "$4" != "" ] && [ "$timeout" == "" ]; then
    timeout=$4
fi



####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

if [ "$timeout" == "" ]; then
	echo "Error:  No timeout value is specified."
	exit 1
fi

if [ -f "/Library/Preferences/DirectoryService/ActiveDirectory.plist" ]; then
	/usr/bin/defaults write /Library/Preferences/DirectoryService/ActiveDirectory "LDAP Connection Timeout" -string $timeout
else
	echo "Error:  This machine is not bound to Active Directory."
	exit 1
fi