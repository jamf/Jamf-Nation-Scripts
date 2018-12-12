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
#	runSophosScan.sh -- Run Sophos Anti-Virus Scan.
#
# SYNOPSIS
#	sudo runSophosScan.sh
#	sudo runSophosScan.sh <mountPoint> <computerName> <currentUsername> <scanPath> <quarantine>
#
#	If there is a hardcoded value specified for the <scanPath> parameter or if there is a value
#	passed to <scanPath> by the Casper Suite, only the specified path will be scanned.  By
#	default, the entire contents of the boot volume will be scanned.
#
#	If there is a hardcoded value specified for the <quarantine> parameter, or if there is a
#	value passed to <quarantine> from the Casper Suite, files will also be quarantined if they
#	are found to be infected.  The files will be quarantined only if passed one of the
#	following values:
#
#		"TRUE"
#		"YES"
#
#
# DESCRIPTION
#	This script will force sophos to perform a virus scan on the hard drive and will quarantine
#	any infected files if desired.  The default behavior of the script is to simply perform a
#	scan of the drive and report back any infected files in the output of the script.
#	Additionally, files can be quarantined if found to be infected with a virus.
#
#	Please note that this script was created using the latest version of Sophos AV available at the
#	time of the script creation (4.9).  Compatibility with versions of Sophos AV created prior to 
#	and post 4.9 is unknown at this time.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Nick Amundsen on October 24, 2008
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

# HARDCODED VALUES FOR "SCANPATH" AND "QUARANTINE" ARE SET HERE
scanPath=""
quarantine=""


# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "SCANPATH"
if [ "$4" != "" ] && [ "$scanPath" == "" ];then
    scanPath=$4
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 5 AND, IF SO, ASSIGN TO "QUARANTINE"
if [ "$5" != "" ] && [ "$quarantine" == "" ];then
    quarantine=$5
fi

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

if [ "$scanPath" == "" ];then
	case $quarantine in "true" | "TRUE" | "yes" | "YES")
		echo "Performing quarantine Sophos Anti-Virus scan on the boot volume..."
		/usr/bin/sweep / -s --stay-on-machine;;
	*)
		echo "Perfomining Sophos Anti-Virus scan on the boot volume..."
		/usr/bin/sweep / -s --stay-on-machine --quarantine;;
	esac
fi

if [ "$scanPath" != "" ];then
	case $quarantine in "true" | "TRUE" | "yes" | "YES")
		echo "Performing quarantine Sophos Anti-Virus scan on $scanPath..."
		/usr/bin/sweep "$scanPath" -s --stay-on-machine;;
	*)
		echo "Perfomining Sophos Anti-Virus scan on $scanPath..."
		/usr/bin/sweep "$scanPath" -s --stay-on-machine --quarantine;;
	esac
fi
