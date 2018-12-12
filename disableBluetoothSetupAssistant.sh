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
#	disableBluetoothSetupAssistant.sh -- Disable the Bluetooth Setup Assisant.
#
# SYNOPSIS
#	sudo disableBluetoothSetupAssistant.sh
#	sudo disableBluetoothSetupAssistant.sh <mountPoint> <computerName> <currentUsername>
#
# DESCRIPTION
#	This script disables the Bluetooth Setup Assistant that appears when an unrecognized bluetooth
#	device is connected to a machine.
#	After running this script, the Bluetooth Setup Assistant will be moved to:
#
#		/Library/Application Support/JAMF/DisabledApplications/
#
#	This way, the Bluetooth Setup Assistant could be re-enabled in the future.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Nick Amundsen on August 24th, 2006
#	- Modified by Nick Amundsen on August 6th, 2008
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

echo "Disabling the Bluetooth Setup Assistant..."

if [ -d "/Library/Application Support/JAMF/DisabledApplications/" ]; then
	/bin/mv '/System/Library/CoreServices/Bluetooth Setup Assistant.app' '/Library/Application Support/JAMF/DisabledApplications/'
else
	/bin/mkdir -p '/Library/Application Support/JAMF/DisabledApplications/'
	/bin/mv '/System/Library/CoreServices/Bluetooth Setup Assistant.app' '/Library/Application Support/JAMF/DisabledApplications/'
fi