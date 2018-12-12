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
#	setWebProxy.sh -- Configure a web proxy for a specified network interface
#
# SYNOPSIS
#	sudo setWebProxy.sh
#	sudo setWebProxy.sh <mountPoint> <computerName> <currentUsername> <networkInterface>
#							<proxyAddress> <port> 
#
# 	If the $networkInterface parameter is specified (parameter 4), this is the Netowrk Interface for
#	which the search domains will be set.  The expected values for the $networkInterface parameter can
#	be found by running the command:
#
#		networksetup -listallnetworkservices
#
#	If the $proxyAddress parameter is specified (parameter 5), this is the proxy address that will
#	be set.
#
#	If the $port parameter is specified (parameter 6), this is the port to which the proxy traffic
#	be passed.
#
# 	If no parameters are specified for parameters 4, 5 or 6, the hardcoded value in the script will be 
#	used.
#
# DESCRIPTION
#	This script will configure the web proxy on the specified network interface.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.1
#
#	- Created by Nick Amundsen on July 11th, 2008
#	- Modified by Nick Amundsen on August 5th, 2008
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################


# HARDCODED VALUES ARE SET HERE
networkInterface=""
proxyAddress=""
port=""


# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "networkInterface"
if [ "$4" != "" ] && [ "$networkInterface" == "" ];then
    networkInterface=$4
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 5 AND, IF SO, ASSIGN TO "proxyAddress"
if [ "$5" != "" ] && [ "$proxyAddress" == "" ];then
    proxyAddress=$5
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 6 AND, IF SO, ASSIGN TO "port"
if [ "$6" != "" ] && [ "$port" == "" ];then
    port=$6
fi

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

if [ "$networkInterface" == "" ]; then
	echo "Error:  No network interface has been specified."
	exit 1
fi

if [ "$proxyAddress" == "" ]; then
	echo "Error:  No proxy address has been specified."
	exit 1
fi

if [ "$port" == "" ]; then
	echo "Error: No port was specified."
	exit 1
fi

OS=`/usr/bin/defaults read /System/Library/CoreServices/SystemVersion ProductVersion | awk '{print substr($1,1,4)}'`

if [[ "$OS" < "10.5" ]]; then
	echo "Setting web proxy for OS $OS..."
	/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Support/networksetup -setwebproxy "$networkInterface" "$proxyAddress" "$port"
else
	echo "Setting web proxy for OS $OS..."
	/usr/sbin/networksetup -setwebproxy "$networkInterface" "$proxyAddress" "$port"
fi