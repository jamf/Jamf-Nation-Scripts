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
#	unbindOD.sh -- Unbind from Open Directory.
#
# SYNOPSIS
#	sudo unbindOD.sh
#	sudo unbindOD.sh <mountPoint> <computerName> <currentUsername> <serverAddress> <username> 
#						<password>
#
# 	If the $serverAddress, $username, and $password parameters are specified (parameters 4, 5, and 
#	6), these will be used to unbind the machine from Open Directory.  The username/password that 
#	should be used in this script should be an Open Directory user that has permissions to 
#	remove/unbind a machine	from Open Directory.
#
# 	If no parameters are specified for parameters 4, 5, and 6, the hardcoded value in the script 
#	will be used.
#
# DESCRIPTION
#	This script will unbind a client machine from an Open Directory domain.
#	The <serverAddress>, <username>, and <password> values can be used with a hardcoded value in the
#	script, or read in as a parameter.  Since the Casper Suite defines the first three parameters as
#	(1) Mount Point, (2) Computer Name and (3) username, we are using the fourth, fifth, and sixth
#	parameters ($4, $5, $6) as the passable parameters. 
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.1
#
#	- Created by Nick Amundsen on August 7th, 2008
#	- Updated by Nick Amundsen on May 6th, 2009
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################


# HARDCODED VALUES ARE SET HERE
serverAddress=""
username=""
password=""

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "serverAddress"
if [ "$4" != "" ] && [ "$serverAddress" == "" ]; then
    serverAddress=$4
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 5 AND, IF SO, ASSIGN TO "username"
if [ "$5" != "" ] && [ "$username" == "" ]; then
    username=$5
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 6 AND, IF SO, ASSIGN TO "password"
if [ "$6" != "" ] && [ "$password" == "" ]; then
    password=$6
fi


####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

if [ "$serverAddress" == "" ]; then
	echo "Error:  No Server Address is specified.  A Server Address must be specified to unbind the machine."
	exit 1
fi

if [ "$username" == "" ] && [ "$password" == "" ]; then
	echo "No username/password is specified.  Attempting to unbind without credentials."
	/usr/sbin/dsconfigldap -r "$serverAddress"
fi

if [ "$username" != "" ] && [ "$password" == "" ]; then
		echo "Error:  No password is specified.  Please specify a network password."
		exit 1
else
	echo "Unbinding the computer from Open Directory..."
	/usr/sbin/dsconfigldap -f -v -r"$serverAddress" -u "$username" -p "$password"	
fi

echo "Removing Custom Authentication Search Paths..."
/usr/bin/sed -e "/		\<string\>\/LDAPv3\/$serverAddress\<\/string\>/d" /Library/Preferences/DirectoryService/SearchNodeConfig.plist > /private/tmp/SearchNodeConfig.plist
/bin/mv /private/tmp/SearchNodeConfig.plist /Library/Preferences/DirectoryService/SearchNodeConfig.plist
/usr/sbin/chown root:admin /Library/Preferences/DirectoryService/SearchNodeConfig.plist
/bin/chmod 500 /Library/Preferences/DirectoryService/SearchNodeConfig.plist

echo "Removing Custom Contact Search Paths..."
/usr/bin/sed -e "/		\<string\>\/LDAPv3\/$serverAddress\<\/string\>/d" /Library/Preferences/DirectoryService/ContactsNodeConfig.plist > /private/tmp/ContactsNodeConfig.plist
/bin/mv /private/tmp/ContactsNodeConfig.plist /Library/Preferences/DirectoryService/ContactsNodeConfig.plist
/usr/sbin/chown root:admin /Library/Preferences/DirectoryService/ContactsNodeConfig.plist
/bin/chmod 500 /Library/Preferences/DirectoryService/ContactsNodeConfig.plist

echo "Restarting Directory Services..."
/usr/bin/killall DirectoryService