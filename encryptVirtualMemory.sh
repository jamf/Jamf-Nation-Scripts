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
#	encryptVirtualMemory.sh -- Encrypts Virtual Memory
#
# SYNOPSIS
#	sudo encryptVirtualMemory.sh
#
# DESCRIPTION
#	This script will encrypt virtual memory.  Please note that a reboot must take place after
#	running the script for the virtual memory to be encrypted.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.1
#
#	- Created by Tedd Herman on December 7th, 2008
#	- Modified by Nick Amundsen on January 5th, 2009
#
####################################################################################################
OS=`/usr/bin/defaults read /System/Library/CoreServices/SystemVersion ProductVersion | awk '{print substr($1,1,4)}'`

if [[ "$OS" < "10.5" ]]; then
	if [ `cat /private/etc/hostconfig | grep ENCRYPTSWAP=-NO-` ]; then
		echo "Encrypting Virtual Memory. Virtual memory will be encrypted upon reboot."
		/bin/cat /private/etc/hostconfig | sed s/ENCRYPTSWAP=-NO-/ENCRYPTSWAP=-YES-/g > /private/tmp/hostconfig
		/bin/mv /private/tmp/hostconfig /private/etc/hostconfig
	else
		echo "Virtual Memory is Already Being Encrypted.  No Changes Will be Made."
	fi
else
	echo "Encrypting Virtual Memory. Virtual memory will be encrypted upon reboot."
	/usr/bin/defaults write /Library/Preferences/com.apple.virtualMemory UseEncryptedSwap -bool yes
fi
exit 0
