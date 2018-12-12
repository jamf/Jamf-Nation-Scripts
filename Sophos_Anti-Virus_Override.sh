#!/bin/bash

####### HISTORY ##############
#
# http://www.sophos.com/en-us/support/knowledgebase/119758.aspx
#
# Written by Tim Kimpton 09.22.2014 
#
# There are multiple machine names that can be used within the OS X operating system; however, these can all differ and lead to some confusion.
# The machine name that we should use, according to Apple's documentation, is the NetBIOS name that is referenced within the com.apple.smb.server.plist file.
#
# Older versions of OS X may not contain the com.apple.smb.server.plist file; if this file cannot be found, we attempt to check the smb.plist file.
#
# Sophos Anti-Virus for OS X will check these files in this order to determine the machine name to send to Sophos Enterprise Console:
#
# The Remote Management System (RMS) that deals with the communication between Sophos Anti-Virus for Mac OS X and the Sophos Enterprise Console can be
# configured to allow the Machine Name, Domain Name, and Computer Description to be overridden and alternative values to be used.
#
############################

####### ENVIRONMENT VARIABLES ###########

# Get the machines current computername
ComputerName=`scutil --get ComputerName`

### Domain Bindings ###

# Apple AD Plugin
AD="YOUR AD"

### Apple AD machine name ###
AADmachine=`dscl /Active\ Directory/$AD/All\ Domains/ -read /Computers/"${ComputerName}"$ | grep RealName | awk '{print $2}'`

##### DO NOT MODIFY BELOW THIS LINE ######

# Check to see if the override is already in the file
if
cat /Library/Sophos\ Anti-Virus/RMS/agent.config | grep ComputerNameOverride > /dev/null 2>&1 ;then

# If it is already in the file just echo out
echo "Override already exists in /Library/Sophos Anti-Virus/RMS/agent.config"

# If the override does not exist then check again the Apple AD plugin against the computer name
elif
dscl /Active\ Directory/$AD/All\ Domains/ -read /Computers/"${ComputerName}"$ > /dev/null 2>&1 ;then
echo "The "${AADmachine}" exists in Apple Directory Services Apple AD Plugin"

# Write the override file to the location
sudo echo "\"ComputerNameOverride\"=\""${AADmachine}""\" >> "/Library/Sophos Anti-Virus/RMS/agent.config"

# Restarting the Sophos RMS Services
launchctl unload -w /Library/LaunchDaemons/com.sophos.managementagent.plist
launchctl unload -w /Library/LaunchDaemons/com.sophos.messagerouter.plist

launchctl load -w /Library/LaunchDaemons/com.sophos.managementagent.plist
launchctl load -w /Library/LaunchDaemons/com.sophos.messagerouter.plist

fi
exit 0

