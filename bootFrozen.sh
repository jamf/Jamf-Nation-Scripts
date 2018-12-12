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
#		http://list.jamfsoftware.com/mailman/listinfo/resourcekit
#
#		http://www.jamfsoftware.com/support/resource-kit
#
#	Please reference our SLA for information regarding support of this application:
#
#		http://www.jamfsoftware.com/support/resource-kit-sla
#
####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#	bootFrozen.sh -- Freezes a Deep Freeze Partition.
#
# SYNOPSIS
#	sudo bootFrozen.sh
#	sudo bootFrozen.sh <mountPoint> <computerName> <currentUsername> <dfUsername> <dfPassword>
#
# DESCRIPTION
#	This script freezes a partition that has been thawed by DeepFreeze.  This script assumes that the
#	partition to which the machine is currently booted is the working DeepFreeze partition.  To
#	freeze a partition that the machine is not currently booted to, see freezePartition.sh
#
#	Note that a reboot is required to finalize the freeze process.  We recommend using the
#	"Reboot" tab in a Casper Remote session or a Casper Policy to perform this process.  This script
#	should be used in the scenario where you would like to freeze the partition to which you are
#	currently booted.  To freeze a partition that you are not booted to (i.e. when using Casper
#	Imaging), please see freezeTargetPartition.sh.
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
dfUsername=""
dfPassword=""

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
if [ "$dfUsername" == "" ];then
	echo "Error:  The parameter 'dfUsername' is blank.  Please specify a user."
	exit 1
fi

if [ "$dfPassword" == "" ];then
	echo "Error:  The parameter 'dfPassword' is blank.  Please specify a password."
	exit 1
fi

/Library/Application\ Support/Faronics/Deep\ Freeze/CLI "$dfUsername" "$dfPassword" bootFrozen

exit 0