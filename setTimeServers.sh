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
#   setTimeServers.sh -- Set a time server.
#
# SYNOPSIS
#   sudo setTimeServer.sh
#   sudo setTimeServer.sh <mountPoint> <computerName> <currentUsername> <timeServer>
#
# DESCRIPTION
#   This script will set a Time Server in the network settings for whichever network interface has
#   been specified.
#
####################################################################################################
#
# HISTORY
#
#   Version: 1.0
#
#   - Created by Tedd Herman on December 29,2008
#
#   Version 2.0
#
#   - Updated by Brock Walters Nov 8 2014
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

# HARDCODED VALUES ARE SET HERE
timeServer=""

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "timeServer"
if [ "$4" != "" ] && [ "$timeServer" == "" ]
then
    timeServer=$4
fi

####################################################################################################
#
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

osx=$(/usr/bin/defaults read /System/Library/CoreServices/SystemVersion ProductVersion | awk '{print $1}')
maj=$(/usr/bin/defaults read /System/Library/CoreServices/SystemVersion ProductVersion | awk '{print substr($1,1,2)}')
ref=$(/usr/bin/defaults read /System/Library/CoreServices/SystemVersion ProductVersion | awk '{print substr($1,4,2)}')

if [ $maj -gt 10 ]
then
  echo
  echo "Check OS string format & OS X systemsetup utility for script compatibility with OS X version $osx"
  echo
  exit
fi

if [ "$timeServer" != "" ]
then
    if [ $ref -lt 5 ]
    then
        echo
        echo "Setting network time server to: $timeServer..."
        /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Support/systemsetup -setnetworktimeserver $timeServer
        /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Support/systemsetup -setusingnetworktime on
        echo
    else
        echo
        echo "Setting network time server to: $timeServer..."
        /usr/sbin/systemsetup -setnetworktimeserver $timeServer
        /usr/sbin/systemsetup -setusingnetworktime on
        echo
    fi
else
    echo
    echo "Error:  The parameter 'timeServer' is blank.  Please specify a time server."
    echo
fi