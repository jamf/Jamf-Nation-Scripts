#!/bin/sh
####################################################################################################
#
# Copyright (c) 2017, JAMF Software, LLC.  All rights reserved.
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
#	displayMessage.sh -- Display a message to the end user.
#
# SYNOPSIS
#	sudo displayMessage.sh
#	sudo displayMessage.sh <mountPoint> <computerName> <currentUsername> <message> <background>
#
#	If the <message> parameter is specified (parameter 4), this is the message that will be
#	displayed to the end users.  
#
#	If the <background> parameter is specified (parameter 5), the
#	message will be displayed and the end user will not need to click "OK" to allow the proces to
#	continue.  Setting the <background> parameter to and of the following values will determine 
#	whether or not the message will be backgrounded:
#		
#		"TRUE"
#		"FALSE"
#		"YES"
#		"NO"
#
#	Parameter 1, 2, and 3 will not be used in this script, but since they are passed by
#	The Caspeer Suite, we will start using parameters at parameter 4.
#	If no parameter is specified for either parameter 4 or 5, the hardcoded value in the script
#	will be used.  If values are hardcoded in the script for the parameters, then they will override
#	any parameters that are passed by The Casper Suite.
#
# DESCRIPTION
#	This script will display a message to the end user with a specified message.  The message can be
#	backgrounded so that a message is displayed and a process such as a policy is delayed until a
#	user clicks the "OK" button.  By default, the process will not be backgrounded and subsequent
#	scripts or commands that run after this script will be delayed until a user clicks "OK".
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.1
#
#	- Created by Nick Amundsen on August 6th, 2008
#	- Updated by Brandon Wenger on November 28th, 2017
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################


# HARDCODED VALUES ARE SET HERE
message=""
background=""

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "message"
if [ "$4" != "" ] && [ "$message" == "" ]; then
    message=$4
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 5 AND, IF SO, ASSIGN TO "background"
if [ "$5" != "" ] && [ "$background" == "" ]; then
    background=$5
fi

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

if [ "$message" == "" ]; then
	echo "Error:  The parameter 'message' is blank.  Please specify a message to be displayed."
	exit 1
fi

case $background in "true" | "TRUE" | "yes" | "YES")
		echo "Displaying backgrounded message to user..."
		/usr/local/bin/jamf displayMessage -message "$message";;
	*)
		echo "Displaying message to user..."
		osascript -e 'tell application "System Events" to display dialog "'"$message" -e '"buttons {"OK"} default button 1';;
esac