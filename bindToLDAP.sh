#!/bin/sh
####################################################################################################
#
# Copyright (c) 2010, JAMF Software, LLC
# All rights reserved.
#
#	Redistribution and use in source and binary forms, with or without
# 	modification, are permitted provided that the following conditions are met:
#		* Redistributions of source code must retain the above copyright
#		  notice, this list of conditions and the following disclaimer.
#		* Redistributions in binary form must reproduce the above copyright
#		  notice, this list of conditions and the following disclaimer in the
#		  documentation and/or other materials provided with the distribution.
#		* Neither the name of the JAMF Software, LLC nor the
#		  names of its contributors may be used to endorse or promote products
#		  derived from this software without specific prior written permission.
#
# 	THIS SOFTWARE IS PROVIDED BY JAMF SOFTWARE, LLC "AS IS" AND ANY
# 	EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# 	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# 	DISCLAIMED. IN NO EVENT SHALL JAMF SOFTWARE, LLC BE LIABLE FOR ANY
# 	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# 	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# 	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# 	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# 	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# 	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
####################################################################################################
#
# SUPPORT FOR THIS PROGRAM
#
# 	This program is distributed "as is" by JAMF Software, LLC's Resource Kit team. For more 
#	information or support for the Resource Kit, please utilize the following resources:
#
#		http://www.jamfsoftware.com/mailing_lists/
#
#		http://www.jamfsoftware.com/jamf_nation/resourcekit.php
#
#	Please reference our SLA for information regarding support of this application:
#
#		http://www.jamfsoftware.com/jamf_nation/resourcekit_sla.php
#
####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#	bindToLDAP.sh -- Bind to LDAP.
#
# SYNOPSIS
#	sudo bindToLDAP.sh
#	sudo bindToLDAP.sh <mountPoint> <computerName> <currentUsername> <serverAddress>
#
# DESCRIPTION
#	This script will bind a Mac OS X Server or Client machine to any LDAP server.
#
#	This script is part of a larger process that is required to bind machines to an LDAP server and
#	is intended to be used for situations in which the built-in binding types (AD, OD, Centrify,
#	Likewise, ADmitMac) are not acceptable.  This script is designed to be used when attribute
#	mappings need to be customized through the Directory Utility to add an LDAP server to Directory
#	Services for authentication and contact lookups.
#
#	The overall process consists of:
#
#		-Manually configuring a machine to read from the LDAP server using the Directory Utility
#		-Creating a package of the file: 
#	
#			/Library/Preferences/DirectoryService/DSLDAPv3PlugInConfig.plist
#
#		-Modifying this script to contain the server address
#		-Deploying the package, and running the script on a targeted client machine
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Nick Amundsen on April 16th, 2010
# 
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################


# HARDCODED VALUES ARE SET HERE
serverAddress=""


# CHECK TO SEE IF VALUES WERE PASSED FOR $4, AND IF SO, ASSIGN THEM
if [ "$4" != "" ] && [ "$serverAddress" == "" ]; then
	serverAddress=$4
fi

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

if [ "$serverAddress" == "" ]; then
	echo "Error:  The parameter 'serverAddress' is blank.  Please specify an IP/DNS address for the LDAP Server."
	exit 1
fi

echo "Enabling LDAPv3 in Directory Services..."
/usr/bin/defaults write /Library/Preferences/DirectoryService/DirectoryService "LDAPv3" "Active"

sleep 10

echo "Adding Custom Authentication Search Paths..."
/usr/bin/defaults write '/Library/Preferences/DirectoryService/SearchNodeConfig' 'Search Policy' -int 3
/usr/bin/defaults write '/Library/Preferences/DirectoryService/SearchNodeConfig' 'Search Node Custom Path Array' -array-add /LDAPv3/$serverAddress

echo "Adding Custom Contact Search Paths..."
/usr/bin/defaults write '/Library/Preferences/DirectoryService/ContactsNodeConfig' 'Search Policy' -int 3
/usr/bin/defaults write '/Library/Preferences/DirectoryService/ContactsNodeConfig' 'Search Node Custom Path Array' -array-add /LDAPv3/$serverAddress

echo "Restarting Directory Services..."
/usr/bin/killall DirectoryService