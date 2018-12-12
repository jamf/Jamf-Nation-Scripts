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
#	activateSophosSafeGuard.sh -- Activate Sophos SafeGuard.
#
# SYNOPSIS
#	sudo activateSophosSafeGuard.sh
#	sudo activateSophosSafeGuard.sh <mountPoint> <computerName> <currentUsername> <sgUsername> 
#			<sgPassword> <localAdmin> <localPassword> <driveToEncrypt>
#
#	If no hardcoded values are specified for the above parameters, and there is a value 
#	passed for the parameters by the Casper Suite, the values passed will apply.
#
#	If there are hardcoded values specified for the above parameters, those values will 
#	supersede any value passed by the Casper Suite.
#
#	Valid options for the <driveToEncrypt> parameter include:
#
#		"uuid" (Actual UUID of the drive you would like to encrypt)
#		"index"
#		"all"
#		"system"
#
#
# DESCRIPTION
#	This script will create a SafeGuard user, and will begin the encrypting a specified drive.
#
#	Please note that this script was created using the latest version of Sophos SafeGuard available
#	at the time of the script creation (05.49.00).  Compatibility with versions of Sophos SafeGuard
#	created prior to and post 05.49.00 is unknown at this time.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Nick Amundsen on May 12, 2010
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

# HARDCODED VALUES ARE SET HERE
sgUsername=""
sgPassword=""
localAdmin=""
localPassword=""
driveToEncrypt=""  # Choose one of these values: "uuid", "all", "index", "system"


# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "sgUsername"
if [ "$4" != "" ] && [ "$sgUsername" == "" ];then
    sgUsername=$4
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 5 AND, IF SO, ASSIGN TO "sgPassword"
if [ "$5" != "" ] && [ "$sgPassword" == "" ];then
    sgPassword=$5
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 6 AND, IF SO, ASSIGN TO "localAdmin"
if [ "$6" != "" ] && [ "$localAdmin" == "" ];then
    localAdmin=$6
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 7 AND, IF SO, ASSIGN TO "localPassword"
if [ "$7" != "" ] && [ "$localPassword" == "" ];then
    localPassword=$7
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 8 AND, IF SO, ASSIGN TO "driveToEncrypt"
if [ "$8" != "" ] && [ "$driveToEncrypt" == "" ];then
    driveToEncrypt=$8
fi


####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

if [ "$sgUsername" == "" ]; then
	echo "Error: Please ensure that the sgUsername parameter contains a value."
	exit 1
fi

if [ "$sgPassword" == "" ]; then
	echo "Error: Please ensure that the sgPassword parameter contains a value."
	exit 1
fi

if [ "$localAdmin" == "" ]; then
	echo "Error: Please ensure that the localAdmin parameter contains a value."
	exit 1
fi

if [ "$localPassword" == "" ]; then
	echo "Error: Please ensure that the localPassword parameter contains a value."
	exit 1
fi

if [ "$driveToEncrypt" == "" ]; then
	echo "Error: Please ensure that the driveToEncrypt parameter contains a value.  Valid values include: uuid, index, all, or system."
	exit 1
fi

# Create the SafeGuard User
echo "Creating SafeGuard user account with username: $sgUsername..."
/usr/bin/sgadmin --add-user --type admin --user "$sgUsername" --password "$sgPassword" --confirm-password "$sgPassword" --authenticate-user "$localAdmin" --authenticate-password "$localPassword"

if [ "$?" == "0" ]; then
	echo "Successfully created user account."
else
	echo "Error: User account creation failed with error: $?"
	exit 1
fi

# Encrypt the drive
echo "Initiating encryption process on disk: $driveToEncrypt..."
/usr/bin/sgadmin --encrypt "$driveToEncrypt" --authenticate-user "$sgUsername" --authenticate-password "$sgPassword"

if [ "$?" == "0" ]; then
	echo "Successfully initiated encryption process."
else
	echo "Error: Disk encryption process failed with error: $?"
	exit 1
fi