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
#	addToODComputerGroup.sh -- Adds a computer to an Open Directory Computer Group.
#
# SYNOPSIS
#	sudo addToODComputerGroup.sh
#	sudo addToODComputerGroup.sh <mountPoint> <computerName> <currentUsername> <domain> 
#	<dirAdminUsername> <dirAdminPassword> <groups>
#
# DESCRIPTION
#	This script will add a Computer that exists in an Open Directory server to an Open Directory
#	computer group or computer list.  The script assumes that the computer group has previously
#	been bound using a "Secure Bind" to the OD server.  Multiple groups can be specified for the
#	"groups" array found below in the variable section.  Example values for the groups hard-coding
#	the groups array are:
#
#		groups=( 'group1' )
#		groups=( 'group1' 'group2' )
#
#	Example values for passing the groups parameter by Casper Remote or a Policy:
#
#		group1 group2
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Nick Amundsen on December 4th, 2008
# 
####################################################################################################

# HARDCODED VALUES ARE SET HERE
domain=""
dirAdminUsername=""
dirAdminPassword=""
groups=( '' )


# CHECK TO SEE IF VALUES WERE PASSED FOR $4, $5, $6, AND $7, AND IF SO, ASSIGN THEM
if [ "$4" != "" ] && [ "$domain" == "" ]; then
	domain=$4
fi

if [ "$5" != "" ] && [ "$dirAdminUsername" == "" ]; then
	dirAdminUsername=$5
fi

if [ "$6" != "" ] && [ "$dirAdminPassword" == "" ]; then
	dirAdminPassword=$6
fi

if [ "$7" != "" ] && [ "$groups" == "" ]; then
	groups=( $7 )
fi

#####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################


if [ "$domain" == "" ]; then
	echo "Error:  The parameter 'domain' is blank.  Please specify an IP/DNS address for the Open Directory Master."
	exit 1
fi

if [ "$dirAdminUsername" == "" ]; then
	echo "Error:  The parameter 'dirAdminUsername' is blank.  Please specify an administrative username for the Open Directory Master."
	exit 1
fi

if [ "$dirAdminPassword" == "" ]; then
	echo "Error:  The parameter 'dirAdminPassword' is blank.  Please specify an administrative password for user $dirAdminUsername."
	exit 1
fi

if [ "$groups" == "" ]; then
	echo "Error:  The parameter 'groups' is blank.  Please specify a group or a list of groups to add the computer to."
	exit 1
fi



# Check to see if the computerName contains a $

if [ "$(scutil --get ComputerName | grep -c '\$')" == "1" ]; then
	localComputerName=`scutil --get ComputerName`
	directoryComputerName=`scutil --get ComputerName`
fi



if [ "$(scutil --get ComputerName | grep -c '\$')" == "0" ]; then
	localComputerName=`scutil --get ComputerName`$
	directoryComputerName=`scutil --get ComputerName`$
fi

echo "Local Computer Name determined to be: $localComputerName"
echo "Directory Computer Name determined to be: $directoryComputerName"
GUID="$(/usr/bin/dscl /LDAPv3/$domain/ -read "/Computers/$directoryComputerName" GeneratedUID | awk '{ print $2 }')"
echo "GUID determined to be: $GUID"

for (( i = 0; i < ${#groups[@]} ; i++))

	do
	
		myGroup="${groups[$i]}"

	

		# Add to the ComputerList
	
		echo "Adding to the $myGroup Computer List..."
	
		/usr/bin/dscl -u "$dirAdminUsername" -P "$dirAdminPassword" /LDAPv3/$domain/ -merge "/ComputerLists/$myGroup" apple-computers "$directoryComputerName"
	
		# Add to the ComputerGroup
	
		echo "Adding to the $myGroup Computer Group..."
		/usr/bin/dscl -u "$dirAdminUsername" -P "$dirAdminPassword" /LDAPv3/$domain/ -merge "/ComputerGroups/$myGroup" apple-group-memberguid "$GUID"
		/usr/bin/dscl -u "$dirAdminUsername" -P "$dirAdminPassword" /LDAPv3/$domain/ -merge "/ComputerGroups/$myGroup" memberUid "$directoryComputerName"
	done