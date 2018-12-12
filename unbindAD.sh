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
#	unbindAD.sh -- Unbind from Active Directory.
#
# SYNOPSIS
#	sudo unbindAD.sh
#	sudo unbindAD.sh <mountPoint> <computerName> <currentUsername> <username> <password>
#
# 	If the $username and $password parameters are specified (parameters 4 and 5), these will be
#	used to unbind the machine from Active Directory.  The username/password that should be used in
#	this script should be an Active Directory user that has permissions to remove/unbind a machine
#	from Active Directory.
#
# 	If no parameters are specified for parameter 4 and 5, the hardcoded value in the script will be
#	used.
#
# DESCRIPTION
#	This script will unbind a client machine from an Active Directory domain.
#	The <username> and <password> values can be used with a hardcoded value in the script, or read 
#	in as a parameter.  Since the Casper Suite defines the first three parameters as (1) Mount 
#	Point, (2) Computer Name and (3) username, we are using the fourth parameter ($4) as the 
#	passable parameter. 
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Nick Amundsen on August 7th, 2008
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################


# HARDCODED VALUES ARE SET HERE
username=""
password=""

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "username"
if [ "$4" != "" ] && [ "$username" == "" ]; then
    username=$4
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 5 AND, IF SO, ASSIGN TO "password"
if [ "$5" != "" ] && [ "$password" == "" ]; then
    password=$5
fi

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

if [ "$username" == "" ]; then
	echo "Error:  No username is specified.  Please specify a network username."
	exit 1
fi

if [ "$password" == "" ]; then
	echo "Error:  No password is specified.  Please specify a network password."
	exit 1
fi


echo "Unbinding the computer from Active Directory..."
/usr/sbin/dsconfigad -r -u "$username" -p "$password"


echo "Restarting Directory Services..."
/usr/bin/killall DirectoryService