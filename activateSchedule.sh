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
#	activateSchedule.sh - Activates the scheduled updates on target computer(s); name of the schedule must be included in the command.
#
# SYNOPSIS
#	sudo activateSchedule.sh
#	sudo actiavteSchedule.sh <targetVolume> <computerName> <username> <dfUsername> <dfPassword> <scheduleName>
#
# DESCRIPTION
#
#	This script activates a schedule that is currently configured in the DeepFreeze application.
#	Please note that the schedule object must already be present on the computers on which this
#	script is being run.  If the schedule is not currently available on the target clients, it can
#	be packaged up and deployed via Composer.
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
scheduleName="" # Example "Macintosh HD"


# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "DFUSERNAME"
if [ "$4" != "" ] && [ "$dfUsername" == "" ];then
    dfUsername=$4
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 5 AND, IF SO, ASSIGN TO "DFPASSWORD"
if [ "$5" != "" ] && [ "$dfPassword" == "" ];then
    dfPassword=$5
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 6 AND, IF SO, ASSIGN TO "SCHEDULENAME"
if [ "$6" != "" ] && [ "$scheduleName" == "" ];then
    scheduleName=$6
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

if [ "$scheduleName" == "" ];then
	echo "Error:  The parameter 'scheduleName' is blank.  Please specify the name of the DeepFreeze schedule you would like to activate."
	exit 1
fi

/Library/Application\ Support/Faronics/Deep\ Freeze/CLI "$dfUsername" "$dfPassword" activateSchedule "$scheduleName"

exit 0