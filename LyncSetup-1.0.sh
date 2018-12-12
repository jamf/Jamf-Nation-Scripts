#!/bin/sh

###########################      About this script      ##########################
#                                                                                #
#   Purpose: Populates user name and email address settings                      #
#            for Lync for Mac. This script resides                               #
#            in /Library/talkingmoose/Scripts and is launched                    #
#            by launch agent net.talkingmoose.LyncSetup.plist.                   #
#                                                                                #
#   Created by William Smith                                                     #
#   Last update May 4, 2012                                                      #
#                                                                                #
#   Version history                                                              #
#   1.2 Added keys to not ask Lync to be the conference provider,                #
#       presence and telephone provider                                          #
#   1.1 Added NetBIOS domain variable for Lion support                           #
#       Removed support for local dscl lookups                                   #
#   1.0 Created LyncSetup-1.0.sh script                                          #
#                                                                                #
#   Instructions                                                                 #
#   Locate the NETBIOSDOMAIN line below and enter your company's NetBIOS domain  #
#   name. Save the script as "LyncSetup-1.0.sh" into each computer's             #
#   /Library/talkingmoose/Scripts folder or any location of your choosing.       #
#   Modify the net.talkingmoose.LyncSetup.plist launchd item to point to this    #
#   script and place it into /Library/LaunchAgents.                              #
#                                                                                #
#   The launchd agent will launch the script at every user login. If it finds    #
#   ~/Library/Preferences/com.microsoft.Lync.plist then the script will exit.    #
#   Otherwise, it will do the following:                                         #
#        1. Determine the current Mac OS version                                 #
#        2. Get user's current login name                                        #
#        3. Read Active Directory for the user's email address                   #
#        4. Populate the user's ~/Library/Preferences/com.microsoft.Lync.plist   #
#           file with the Lync logon information.                                #
#        5. Set the preference to not show the license agreement.                #
#        6. Write details of the setup to ~/Library/Logs/LyncSetup.log.          #
#                                                                                #
#                                                                                #
##################################################################################



# Running checkSetupDone function to determine if the rest of this script needs to run.
# Yes, if $HOME/Library/Preferences/com.microsoft.Lync.plist file does not exist.
# Otherwise, assume this setup script has already run for this user and does not
# need to run again.


checkSetupDone()	{

	if [ -f $HOME/Library/Preferences/com.microsoft.Lync.plist ] ; then
		exit 0
	fi

}



populateUserInformation()	{

	# Logfile

	LOGFILE="$HOME/Library/Logs/LyncSetup.log"

	# Script version

	SCRIPTVERSION=$0
	date "+%A %m/%d/%Y %H:%M:%S     Running Script: $SCRIPTVERSION" >> $LOGFILE




	# Enter your company NetBIOS domain name here. Necessary for Mac OS X 10.7 and later.

	NETBIOSDOMAIN="TALKINGMOOSE"




	# Get Mac OS version

	MACOSVERSION=$( ( sw_vers -buildVersion ) | awk '{ print substr( $0, 0, 2 ) }' )

	if [ $MACOSVERSION -gt 10 ] ; then
		date "+%A %m/%d/%Y %H:%M:%S     Mac OS X version is Lion or higher." >> $LOGFILE
	else
		date "+%A %m/%d/%Y %H:%M:%S     Mac OS X version is either Leopard or Snow Leopard." >> $LOGFILE
	fi




	# Get current username

	USERNAME=$( id -un )

	if [ $? = 0 ] ; then
		date "+%A %m/%d/%Y %H:%M:%S     User name is $USERNAME." >> $LOGFILE
	else
		date "+%A %m/%d/%Y %H:%M:%S     ERROR! Unable to read user name." >> $LOGFILE
	fi




	# Look up user email address

	if [ $MACOSVERSION -gt 10 ] ; then
		EMAILADDRESS=$( dscl "/Active Directory/$NETBIOSDOMAIN/All Domains/" -read /Users/$USERNAME EMailAddress | awk 'BEGIN {FS=" "} {print $2}' )
	else
		EMAILADDRESS=$( dscl "/Active Directory/All Domains/" -read /Users/$USERNAME EMailAddress | awk 'BEGIN {FS=" "} {print $2}' )
	fi

	if [ $? = 0 ] ; then
		date "+%A %m/%d/%Y %H:%M:%S     User email address is $EMAILADDRESS." >> $LOGFILE
	else
		date "+%A %m/%d/%Y %H:%M:%S     ERROR! Unable to read user email address." >> $LOGFILE
	fi




	# Write user information to Lync preferences file

	defaults write $HOME/Library/Preferences/com.microsoft.Lync UserIDMRU '( { LogonName = '$USERNAME'; UserID = '\"$EMAILADDRESS\"'; } )'

	if [ $? = 0 ] ; then
		date "+%A %m/%d/%Y %H:%M:%S     User logon name set to $USERNAME and user ID set to $EMAILADDRESS." >> $LOGFILE
	else
		date "+%A %m/%d/%Y %H:%M:%S     ERROR! Unable to set user logon name to $USERNAME and user ID to $EMAILADDRESS." >> $LOGFILE
	fi




	# Accept license agreement - Prevents initial license agreement from appearing for each user

	defaults write $HOME/Library/Preferences/com.microsoft.Lync acceptedSLT140 -bool true
	
	if [ $? = 0 ] ; then
		date "+%A %m/%d/%Y %H:%M:%S     License agreement accepted." >> $LOGFILE
	else
		date "+%A %m/%d/%Y %H:%M:%S     ERROR! Unable to accept license agreement." >> $LOGFILE
	fi
	fi




	# Do not show conference provider alert

	defaults write $HOME/Library/Preferences/com.microsoft.Lync DoNotShowConfProviderAlert -bool true
	
	if [ $? = 0 ] ; then
		date "+%A %m/%d/%Y %H:%M:%S     Set do not show conference provider alert." >> $LOGFILE
	else
		date "+%A %m/%d/%Y %H:%M:%S     ERROR! Unable to set do not show conference provider alert." >> $LOGFILE
	fi




	# Do not show presence provider alert

	defaults write $HOME/Library/Preferences/com.microsoft.Lync DoNotShowPresenceProviderAlert -bool true
	
	if [ $? = 0 ] ; then
		date "+%A %m/%d/%Y %H:%M:%S     Set do not show presence alert." >> $LOGFILE
	else
		date "+%A %m/%d/%Y %H:%M:%S     ERROR! Unable to set do not show presence alert." >> $LOGFILE
	fi




	# Do not show telephone provider alert

	defaults write $HOME/Library/Preferences/com.microsoft.Lync DoNotShowTelProviderAlert -bool true
	
	if [ $? = 0 ] ; then
		date "+%A %m/%d/%Y %H:%M:%S     Set do not show telephone provider alert." >> $LOGFILE
	else
		date "+%A %m/%d/%Y %H:%M:%S     ERROR! Unable to set do not show telephone provider alert." >> $LOGFILE
	fi




	# Script spacer - adds a couple of blank lines to the end of the log session

	awk 'BEGIN { print "\n" }' >> $LOGFILE

}

checkSetupDone
populateUserInformation

exit 0