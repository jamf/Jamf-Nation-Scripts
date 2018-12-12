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
#	secureBonjour.sh -- Disables DNS auto-discovery service required for Bonjour.
#
# SYNOPSIS
#	sudo secureBonjour.sh
#
# DESCRIPTION
#	This script will disable bonjour auto-discovery via DNS Service Discovery.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.2
#
#	- Created by Tedd Herman on December 29th, 2008
#	- Modified by Nick Amundsen on January 4th, 2009
#	- Modified by Nick Amundsen on September 9th, 2010
#		-Changed to using MultiCast advertisements with Bonjour enabled per Apple KB article:
#	
#				http://support.apple.com/kb/HT3789
#
####################################################################################################
# Get the major version of the OS and format it in an acceptable form for shell scripting
OS=`/usr/bin/defaults read /System/Library/CoreServices/SystemVersion ProductVersion | awk '{print substr($1,1,4)}'`
echo "Securing Bonjour..."
launchDaemon="/System/Library/LaunchDaemons/com.apple.mDNSResponder.plist"
disabledFolderLocation="/Library/Application Support/JAMF/DisabledLaunchDaemons"
isCurrentlyRunning=`/bin/launchctl list |grep -c com.apple.mDNSResponder`

if [[ "$OS" < "10.6" ]]; then
	# Disable Bonjour for 10.5 or earlier
	if [ "$isCurrentlyRunning" -gt "0" ];then
		#Unload DNS Discovery from active services if running
		echo "Found DNS discovery running.  Unloading DNS discovery..."
		/bin/launchctl unload -w "$launchDaemon"
	fi

	if [ ! -d "$disabledFolderLocation" ];then
		/bin/mkdir "$disabledFolderLocation"
	fi

	if [ -f "$launchDaemon" ];then
		echo "Disabling DNS discovery..."
		/bin/mv "$launchDaemon" "$disabledFolderLocation/com.apple.mDNSResponder.plist"
	fi
else
	# Disable the Bonjour advertising service in 10.6 since unloading Bonjour altogether breaks DNS
	if [ "$isCurrentlyRunning" -gt "0" ];then
		#Check to see if the Bonjour advertising service is already disabled
		advertisingStatus=`/usr/bin/plutil -convert xml1 "$launchDaemon";/bin/cat "$launchDaemon" | grep "<string>-NoMulticastAdvertisements</string>"`
		if [ "$advertisingStatus" == "" ]; then
			#Bonjour advertising service is enabled
			#Unload DNS Discovery from active services if running
			echo "Found Bonjour Advertisement Service running.  Unloading DNS discovery..."
			/bin/launchctl unload -w "$launchDaemon"
			
			#Add flag to the launchDaemon to disable Bonjour advertising
			echo "Adding option to disable Bonjour Advertisements to DNS discovery..."
			/usr/bin/defaults write "/System/Library/LaunchDaemons/com.apple.mDNSResponder" ProgramArguments -array-add "-NoMulticastAdvertisements"
			/usr/sbin/chown root:wheel "$launchDaemon"
			/bin/chmod 644 "$launchDaemon"
			
			#Load DNS Discovery back in to launchd
			echo "Loading DNS discovery..."
			/bin/launchctl load -w "$launchDaemon"
		else
			#DNS Discovery is loaded, but Bonjour Advertisement Service is not enabled
			echo "DNS Discovery is loaded, but Bonjour Advertisement Services are not enabled."
		fi
	fi
fi