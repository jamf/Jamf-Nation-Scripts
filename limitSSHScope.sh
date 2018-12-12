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
#	limitSSHScope.sh -- Limit access to SSH to a single account.
#
# SYNOPSIS
#	sudo limitSSHScope.sh
#	sudo limitSSHScope.sh <mountPoint> <computerName> <currentUsername> <targetUsername>
#
# 	If the $targetUsername parameter is specified (parameter 4), this is the account that will be 
# 	granted access to SSH.
#
# 	If no parameter is specified for parameter 4, the hardcoded value in the script will be used.
#
# DESCRIPTION
#	This script grants SSH access to an individual account on computers running Mac OS X 10.5
#	and later. It can be used with a hardcoded value in the script, or read in as a parameter.
#	Since the Casper Suite defines the first three parameters as (1) Mount Point, (2) Computer
#	Name and (3) username, we are using the forth parameter ($4) as the passable parameter. 
#	We do not use $3 since it may not match up to the username that we want to grant access for.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.1
#
#	- Created by Nick Amundsen on April 4th, 2008
#	- Modified by Zach Halmstad on August 1st, 2008
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################


# HARDCODED VALUE FOR "USERNAME" IS SET HERE
username=""


# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "USERNAME"
if [ "$4" != "" ];then
    username=$4
fi



####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################
if [ "$username" == "" ]; then
	echo "Error:  The parameter 'username' is blank.  Please specify a value."
	exit 1
fi

userID=`/usr/bin/dscl localhost -read /Local/Default/Users/$username | grep GeneratedUID | awk '{print $2}'`

if [ "$userID" != "" ];then
	echo "Granting SSH Access for $username with GUID $userID"
	/usr/bin/dscl localhost -create /Local/Default/Groups/com.apple.access_ssh
	/usr/bin/dscl localhost -append /Local/Default/Groups/com.apple.access_ssh GroupMembership "$username"
	/usr/bin/dscl localhost -append /Local/Default/Groups/com.apple.access_ssh GroupMembers "$userID"
	/usr/bin/dscl localhost -append /Local/Default/Groups/com.apple.access_ssh RealName 'Remote Login Group'
	/usr/bin/dscl localhost -append /Local/Default/Groups/com.apple.access_ssh PrimaryGroupID 104
else
	echo "No record was found for $username"
fi



