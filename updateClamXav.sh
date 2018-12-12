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
#	updateClamXav.sh -- Update virus definitions for ClamXav
#
# SYNOPSIS
#	sudo updateClamXav.sh
#	sudo updateClamXav.sh <mountPoint> <computerName> <currentUsername> <defsDate> <defsVersion>
#
# DESCRIPTION
#	This script will download the latest virus definitions for ClamXav for mac to ensure that
#	the latest definition set is being used whenever ClamXav is run.
#
#	Please note that this script was created using the latest version of ClamXav available at the
#	time of the script creation (1.1.1).  Compatibility with versions of ClamXav created prior to 
#	and post 1.1.1 is unknown at this time.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Nick Amundsen on November 5, 2008
#
####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

versionBefore=`/usr/local/clamXav/bin/freshclam --version | sed s:/:\ :g | awk '{print $3}'`
echo "Currently installed definition file: $versionBefore"

echo "Updating ClamXav definitions..."
/usr/local/clamXav/bin/freshclam --quiet --log="/usr/local/clamXav/share/clamav/freshclam.log"

versionAfter=`/usr/local/clamXav/bin/freshclam --version | sed s:/:\ :g | awk '{print $3}'`
if [ $versionBefore == $versionAfter ]; then
	echo "Virus Deinitions are already up to date."
else
	echo "Updated definition file: $versionAfter"
fi