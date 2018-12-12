#!/bin/bash
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
#	disableBluetooth.sh -- Disable the Bluetooth drivers.
#
# SYNOPSIS
#	sudo disableBluetooth.sh
#	sudo disableBluetooth.sh <mountPoint> <computerName> <currentUsername> <targetVolume>
#	sudo disableBluetooth.sh <mountPoint> <computerName> <currentUsername> <kextid>
#
# DESCRIPTION
#
#	If executed on OS X version 10.10 or prior this script disables the Bluetooth drivers
#	thereby disabling all functionality of the Bluetooth receiver. After running the script
# 	the Bluetooth drivers will be moved to:
#
#		/Library/Application\ Support/JAMF/DisabledExtensions/
#
#	so that Bluetooth can be re-enabled in the future. After running this script the computer
#   will need to be rebooted for the settings to take effect.
#
#	If executed on OS X 10.11 or later this script attempts to locate the Broadcom Bluetooth
#   kernel extension & safely unloads it using the kextunload binary thereby disabling the
#	functionality of the Bluetooth receiver.
#
#	(See: "man -k kext" for more information on kernel extension binaries.)
#
#	On OS X 10.11 or later this script does not make a persistent change to Bluetooth function.
#	Rebooting the computer will load all kernel extensions that are part of the default OS X
#	install per Apple's System Integrity Protection. Kernel extensions may only be moved if
#	System Integrity Protection is disabled.
#
#	It is possible that this particular Bluetooth kernel extension may not be present. If so, 
#	the script will fail with an error message accordingly. To obtain the bundle identifier of
#	the Bluetooth kernel extension in use should it be necessary use the following command:
#	
#	"sudo kextfind -B -i -s bluetooth"
#
#	The kernel extension bundle identifier in use can then be hard coded into the "value" variable
#	below, passed as the 4th argument on the command line when executing the script (see usage above)
#	or as parameter 4 when deploying the script as a payload from the JSS.
#
####################################################################################################
#
# HISTORY
#
#	Version: 2.0
#
#	- Created by Nick Amundsen August 6 2008
#	- Updated by Nick Amundsen June 11 2009
#	- Updated by Nick Amundsen January 21 2010
#	- Updated by Brock Walters November 14 2015
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

# HARDCODED VALUE FOR IS SET HERE (OS X 10.10 & PRIOR: targetVolume", OS X 10.11 & LATER: kextid)
# PASTE TEXT IN BETWEEN DOUBLE QUOTES (eg. value="Volumes/Macintosh HD")

value=""

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4
if [ "$4" != "" ] && [ "$value" == "" ]
then
    value=$4
fi

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

if [ $EUID -ne 0 ]
then
    >&2 /bin/echo $'\nThis script must be run as the root user!\n'
    exit
fi

ref=$(/usr/bin/sw_vers -productVersion | awk '{print substr($1,4,2)}')

if [ "$ref" -le 10 ] && [ "$value" != "" ]
then
	targetVolume="$value"
	echo "Disabling the Bluetooth drivers on target volume $targetVolume..."
	if [ -d "$targetVolume/Library/Application Support/JAMF/DisabledExtensions/" ]
	then
		/bin/mv "$targetVolume/System/Library/Extensions/IOBluetooth"* "$targetVolume/Library/Application Support/JAMF/DisabledExtensions/"
	else
		/bin/mkdir -p "$targetVolume/Library/Application Support/JAMF/DisabledExtensions/"
		/bin/mv "$targetVolume/System/Library/Extensions/IOBluetooth"* "$targetVolume/Library/Application Support/JAMF/DisabledExtensions/"
	fi
elif [ "$ref" -ge 11 ]
then
	kextid="$value"
	if [ "$kextid" = "" ]
	then
		broadcomkextid=$(/usr/sbin/kextstat -l | /usr/bin/awk '/Broadcom/{print $6}')
		/sbin/kextunload -b "$broadcomkextid"
	else
		>&2 /bin/echo $'\nerror: Broadcom Bluetooth kernel extension was not found.\n'
	fi
	if [ "$kextid" != "" ]
	then
		/sbin/kextunload -b "$kextid"
	fi
fi


