#!/bin/bash

#####################################################################################################################
#
# Created by Tim Kimpton
#
# 30/05/2013
#
# It appears that with ADmitMac v7 on OS X 10.7 and 10.8, the local Directory Services accounts 
# for Mobile Accounts are created without any reference to the sAMAccountName.
# 
# This means that user record names do not shown in the alias field of the users accounts in System Preferences
# 
# For example jbloggs logs in the first time ok but subsequent logins will only work with jbloggs@FQDN
#
# Alternatively i have created this script to run as a login policy to address this issue.
#
#####################################################################################################################

########## ENVIRONMENT VARIABLES ################

# Enter your Fully Qualified Domain Name
FQDN="XXX"

# Specify a RL mobile user account
MobileAccount=`ls -l /dev/console | cut -d " " -f4 | grep $FQDN`

# Get the currently logged in user without the FQDN
user=`ls -l /dev/console | cut -d " " -f4 | cut -d@ -f1`

############ DO NOT MODIFY BELOW THIS LINE ##############

if
# Check to see if the currently logged in user is a rufus mobile account
ls -l /dev/console | cut -d " " -f4 | grep $FQDN
then

# See if the logged in mobile account already has an alias
if
sudo dscl . -read /Users/$MobileAccount | egrep RecordName | cut -d" " -f3 | egrep $user
then echo "alias exists"
else

# Append the mobile account with the users AD login name as an alias
sudo dscl . -append /Users/$MobileAccount RecordName $user
fi
fi
exit 0

