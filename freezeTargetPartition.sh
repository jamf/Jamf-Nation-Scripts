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
#	freezeTargetPartition.sh -- Freezes a Deep Freeze Partition.
#
# SYNOPSIS
#	sudo freezeTargetPartition.sh
#	sudo freezeTargetPartition.sh <mountPoint> <computerName> <currentUsername> <dfUsername> <dfPassword>
#
# DESCRIPTION
#	This script thaws a partition that has been frozen by DeepFreeze.  By default, the script
#	will accept the target drive that is passed by default when running a script via the Casper
#	Suite.  If you desire to thaw an alternative partition, one can be specified.  If specifying
#	the target partition manually, the format to be used should be the name of the drive.
#		
#		Example:
#	
#			A drive that is mounted at /Volumes/Macintosh\ HD
#
#			Should be speficied as follows:
#				targetPartition="Macintosh HD"
#
#	This script is best used in a scenario where you are imaging a machine with Casper Imaging and
#	you would like to ensure that when booting into an imaged partition for the first time that the
#	partition is in a "frozen" state.  This script should be run in an "After" priority when being
#	run as part of the imaging process.  If you would like to freeze a partition to which the target
#	machine is currently booted, please see bootFrozen.sh.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Nick Amundsen and Jake Mosey on November 3rd, 2008
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################


# HARDCODED VALUES SET HERE
targetPartition="" # Example "Macintosh HD"
dfUsername=""
dfPassword=""

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 1 AND, IF SO, ASSIGN TO "TARGETUSERNAME"
if [ "$1" != "" ] && [ "$targetPartition" == "" ];then
    targetPartition=$1
    passedByCasper="1"
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "DFUSERNAME"
if [ "$4" != "" ] && [ "$dfUsername" == "" ];then
    dfUsername=$4
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "DFPASSWORD"
if [ "$5" != "" ] && [ "$dfPassword" == "" ];then
    dfPassword=$5
fi

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################
if [ "$passedByCasper" == "1" ];then
	#Format the targetPartition variable into an accepted format
	diskIdentifier=`df | grep "^$1" | grep "$1$" | awk '{print $1}' | sed s:/dev/::g`
	targetPartition=`diskutil info -plist $diskIdentifier | grep -A 1 VolumeName | grep string | sed s:"<string>"::g | sed s:"</string>"::g | awk '{sub(/^[ \t]+/, ""); print}'`
fi

if [ "$targetPartition" == "" ];then
	echo "Error:  The parameter 'targetPartition' is blank.  Please specify a partition."
	exit 1
fi

if [ "$dfUsername" == "" ];then
	echo "Error:  The parameter 'dfUsername' is blank.  Please specify a user."
	exit 1
fi

if [ "$dfPassword" == "" ];then
	echo "Error:  The parameter 'dfPassword' is blank.  Please specify a password."
	exit 1
fi

"$1/Library/Application Support/Faronics/Deep Freeze/CLI" "$dfUsername" "$dfPassword" freezePartition "$targetPartition"

exit 0