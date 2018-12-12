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
#	disableiSight.sh -- Disable the iSight Camera drivers.
#
# SYNOPSIS
#	sudo disableiSight.sh
#	sudo disableiSight.sh <targetVolume> <computerName> <currentUsername>
#
# DESCRIPTION
#	This script disables the iSight Camera drivers, thereby disabling all functionality of the 
#	iSight Camera.
#	
#	After running this script, the iSight Camera drivers will be moved to:
#
#		/Library/Application Support/JAMF/DisabledExtensions/
#
#	This way, the iSight Camera drivers could be re-enabled in the future.  After running this 
#	script, the machine will need to be rebooted for the settings to take effect.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.3
#
#	- Created by Nick Amundsen on August 6th, 2008
#	- Updated by Nick Amundsen on June 3rd, 2009
#	- Updated by Nick Amundsen on June 25th, 2009
#	- Updated by Nick Amundsen on November 19th, 2010
#		-Added support for disabling an additional extension that made it into 10.6 which
#		 prevented the iSight Camera from getting disabled.
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

# HARDCODED VALUE FOR "targetVolume" IS SET HERE
targetVolume=""


# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 1 AND, IF SO, ASSIGN TO "USERNAME"
if [ "$1" != "" ] && [ "$targetVolume" == "" ];then
    targetVolume=$1
fi

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

echo "Disabling the iSight Camera Drivers..."

if [ -d "$targetVolume/Library/Application Support/JAMF/DisabledExtensions/" ]; then
	/bin/mv "$targetVolume/System/Library/Extensions/Apple_iSight.kext" "$targetVolume/Library/Application Support/JAMF/DisabledExtensions/"
	/bin/mv "$targetVolume/System/Library/QuickTime/QuickTimeUSBVDCDigitizer.component" "$targetVolume/Library/Application Support/JAMF/DisabledExtensions/"
	/bin/mv "$targetVolume/System/Library/PrivateFrameworks/CoreMediaIOServicesPrivate.framework/Versions/A/Resources/VDC.plugin" "$targetVolume/Library/Application Support/JAMF/DisabledExtensions/"
	/bin/mv "$targetVolume/System/Library/PrivateFrameworks/CoreMediaIOServices.framework/Versions/A/Resources/VDC.plugin/Contents/VDC" "$targetVolume/Library/Application Support/JAMF/DisabledExtensions/"
else
	/bin/mkdir -p "$targetVolume/Library/Application Support/JAMF/DisabledExtensions/"
	/bin/mv "$targetVolume/System/Library/Extensions/Apple_iSight.kext" "$targetVolume/Library/Application Support/JAMF/DisabledExtensions/"
	/bin/mv "$targetVolume/System/Library/QuickTime/QuickTimeUSBVDCDigitizer.component" "$targetVolume/Library/Application Support/JAMF/DisabledExtensions/"
	/bin/mv "$targetVolume/System/Library/PrivateFrameworks/CoreMediaIOServicesPrivate.framework/Versions/A/Resources/VDC.plugin" "$targetVolume/Library/Application Support/JAMF/DisabledExtensions/"
	/bin/mv "$targetVolume/System/Library/PrivateFrameworks/CoreMediaIOServices.framework/Versions/A/Resources/VDC.plugin/Contents/VDC" "$targetVolume/Library/Application Support/JAMF/DisabledExtensions/"
fi