#!/bin/sh
####################################################################################################
#
# Copyright (c) 2011, JAMF Software, LLC.  All rights reserved.
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
#####################################################################################################
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
#####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#	configureADmitMac.sh -- Change some of ADmitMac's configuration options
#
# SYNOPSIS
#	sudo configureADmitMac.sh
#
# DESCRIPTION
#	This script will modify the following ADmitMac configuration options:
#		
#		-Enable Workgroup Manager MCX functionality
#		-Set ADmitMac LANMAN policy to use "Send NTLMv2 response only"
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Tim Kimpton on May 5, 2011
#
####################################################################################################
# 
# SCRIPT CONTENTS
#
####################################################################################################
# Set ADmitMac to Enable WorkGroup Manager
/usr/libexec/PlistBuddy -c 'Set:Sysvol\ Enabled 1'
/Library/Preferences/com.thursby.CIFSPlugin.plist

# Set ADmitMac LANMAN policy to use "Send NTLMv2 response only" (Client will
use NTLMv2 or Kerberos authentication only)
/usr/libexec/PlistBuddy -c 'Set:Profiles:0:DAVE\ Networking:LANMAN\ Client\ Policy 3' /Library/Preferences/com.thursby.DAVE.cifsd.plist