#!/bin/bash

############################################## HISTORY #############################################
#
# http://www.sophos.com/en-us/support/knowledgebase/119758.aspx
#
# Written by Tim Kimpton 09.23.2014
#
# The Remote Management System (RMS) that deals with the communication between Sophos Anti-Virus 
# for Mac OS X and the Sophos Enterprise Console can be configured to allow the Machine Name, 
# Domain Name, and Computer Description to be overridden and alternative values to be used.
#
# For more information see  http://www.sophos.com/en-us/support/knowledgebase/119758.aspx
#
# This script does the following
# 
# 1. Checks if an override already exists and if so exits
#
# 2. Checks if the machine is bound to the domain & computer name exists in directory services 
#
# 3. Writes the computer name into the override 
#
# 4. Restarts the relevant Sophos Anti-Virus Services
#
####################################################################################################


####### ENVIRONMENT VARIABLES ###########

# Get the machines current computername
ComputerName=`scutil --get ComputerName`

### Domain Bindings ###

# Apple AD Plugin
AD="YOUR DOMAIN"

### Apple AD machine ###
MachineCheck=`dscl /Active\ Directory/$AD/All\ Domains/ -read /Computers/"${ComputerName}"$ | grep RealName | awk '{print $2}'`

### Check to see if the machine is bound to AD with the Apple Plugin
DomainCheck=`dsconfigad -show | grep "Active Directory Domain" | awk '{print $5}'`

##### DO NOT MODIFY BELOW THIS LINE ######

# Check to see if the ComputerName is already in the file
if
cat /Library/Sophos\ Anti-Virus/RMS/agent.config | grep ComputerNameOverride > /dev/null 2>&1 ;then

# If it is already in the file just echo out
echo "Sophos Anti-Virus Override already exists!"

# If the override does not exist then check again the Apple AD plugin against the computer name
elif [ "${DomainCheck}"  = corp.service-now.com ] && [ "${MachineCheck}" = "${ComputerName}" ] ; then
echo "The machine"${ComputerName}" exists in Active Directory and bound to "${DomainCheck}"
Creating the Sophos Anti-Virus Override"

# Write the override file to the location
sudo echo "\"ComputerNameOverride\"=\""${AADmachine}""\" >> "/Library/Sophos Anti-Virus/RMS/agent.config"

# Restarting the Sophos RMS Services
launchctl unload -w /Library/LaunchDaemons/com.sophos.managementagent.plist
launchctl unload -w /Library/LaunchDaemons/com.sophos.messagerouter.plist

launchctl load -w /Library/LaunchDaemons/com.sophos.managementagent.plist
launchctl load -w /Library/LaunchDaemons/com.sophos.messagerouter.plist

fi
exit 0
