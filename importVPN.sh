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
#	importVPN.sh -- Import VPN Settings.
#
# SYNOPSIS
#	sudo importVPN.sh
#	sudo importVPN.sh <mountPoint> <computerName> <currentUsername> <vpnFilePath> <vpnInterfaceName>
#
# DESCRIPTION
#	This script will import a .networkConnect file that has been packaged and deployed to a 
#	system.
#
#	Prior to running this script, the VPN should be configured on a machine, and a
#	configuration should be created.  Once a VPN has been configured, navigate to the
#	Network pane within the System Preferences application and highlight the VPN service you
#	wish to export.  Then click the settings button near the "+" and "-" icon and select
#	"Export Configurations".  Save the file to a location like the Desktop.  Finally, create a
#	package of this file using Composer.
#
#	When deploying the package, ensure that this script has been edited so that the
#	"vpnFilePath" parameter properly points to the location of the .networkConnect file as it
#	was packaged.  Deploy the package, and run the script with a priority of "After" to import
#	the VPN settings for the user.  Please note that a user does need to be logged in while this
#	script is run.  We recommend running it via a policy triggered by "login" or "Self Service."
#
#	The VPN network interface name will remain generic unless the "vpnInterfaceName" variable is
#	specified.  Please note that the .networkConnect file does not contain the name of the
#	inteface.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Nick Amundsen on May 10th, 2010
# 
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

# HARDCODED VALUES SET HERE

vpnFilePath=""		# Set this parameter to the path where the .networkConnect file will end up on the system.
					# Example: "/Library/Application Support/JAMF/vpn.networkConnect"
					
vpnInterfaceName="" # Set this parameter to the name that should be set for the VPN in the System Preferences pane.
					# Example: "Company VPN"





# CHECK TO SEE IF A VALUE WERE PASSED IN FOR PARAMETERS $4 AND, IF SO, ASSIGN THEM
if [ "$4" != "" ] && [ "$vpnFilePath" == "" ]; then
	vpnFilePath=$4
fi

if [ "$5" != "" ] && [ "$vpnInterfaceName" == "" ]; then
	vpnInterfaceName=$5
fi

####################################################################################################
# 
# VARIABLE VERIFICATION FUNCTION
#
####################################################################################################

verifyVariable () {
eval variableValue=\$$1
if [ "$variableValue" != "" ]; then
	echo "Variable \"$1\" value is set to: $variableValue"
else
	echo "Variable \"$1\" is blank.  Please assign a value to the variable."
	exit 1
fi
}

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

# Verify Variables

verifyVariable vpnFilePath

# If  vpnInterfaceName is left blank, then it will not get renamed.


#Unlock the system.preferences privilege to allow this script to apply VPN network adapter
/usr/libexec/PlistBuddy -c "Set rights:system.preferences:class allow" /etc/authorization

#Ensure assistive device access is enabled
if [ -f /private/var/db/.AccessibilityAPIEnabled ];then
		echo "Assistive Device Access is already enabled."
	else
		echo "Enabling Access for Assistive Devices for Script to Properly Run..."
		/usr/bin/touch /private/var/db/.AccessibilityAPIEnabled
fi

#Import .networkConnect file
echo "Importing Network Adapter..."
/usr/bin/open "$vpnFilePath"

#Click the "Apply" button for the user
/usr/bin/osascript << EOF > /dev/null 2>&1

tell application "System Events"
	tell process "System Preferences"
		tell window "Network"
			
			click button "Apply"
			click button "Show VPN status in menu bar"
		end tell
         end tell
end tell

EOF

#Rename the interface if the variable was specified
if [ "$vpnInterfaceName" != "" ]; then
	echo "Renaming the VPN interface to $vpnInterfaceName..."
	/usr/sbin/networksetup -renamenetworkservice "VPN (L2TP)" "$vpnInterfaceName"
fi

#Lock the system.preferences privilege
/usr/libexec/PlistBuddy -c "Set rights:system.preferences:class user" /etc/authorization

#Quit System Preferences
/usr/bin/osascript << EOF > /dev/null 2>&1

tell application "System Events"
	tell application "System Preferences" to quit
end tell

EOF

#Display Dialog
/usr/sbin/jamf displayMessage -message "VPN Imported" -background

#Return all network adapters
echo "The following network adapters are present after the import:\n$(/usr/sbin/networksetup -listallnetworkservices)"