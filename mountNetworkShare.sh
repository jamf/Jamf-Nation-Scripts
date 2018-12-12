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
#	mountNetworkShare.sh -- Mount a network share.
#
# SYNOPSIS
#	sudo mountNetworkShare.sh
#	sudo mountNetworkShare.sh <mountPoint> <computerName> <loginUsername> <shareUsername>
#								<authType> <password> <mountType> <share>
#
# DESCRIPTION
#	This script was designed to mount a network share on an event such as user login, or through a
#	self service policy.  Using Casper's policy engine, a policy can be scoped so that
#	users and groups (local or directory-based) will mount run this script, and therefore mount the
#	assigned network share.  For directory-based users, it is recommended to use the "kerberos"
#	authentication type.  For local users, the "password" authentication type must be used.
#
#	For kerberos authentication to work properly, the user must be able to manually mount the share
#	when logged in by navigating to "Go" > "Connect to Server..." in the Finder and the user must be
#	able to mount the share without authenticating.  To ensure that your directory users are
#	obtaining kerberos tickets properly, navigate to "System" > "Library" > "CoreServices" and open
#	the "Kerberos Ticket Viewer" application while a directory user is logged in.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.3
#
#	- Created by Nick Amundsen on May 8th, 2009
#	- Updated by Cam Evjen on March 5, 2010
#	- Updated by Nick Amundsen on April 30th, 2010
#	- Updated by Nick Amundsen on October 12th, 2010
#		- Improved Error Handling
#		- Simplified Variables
#		- Added Support for Reading SMB Paths from DFS Referrals
# 
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

# HARDCODED VALUES SET HERE
shareUsername="$3"	#The username of the user to be used to mount the share - leaving this to $3 will mount the share as the currently logged in user
authType="kerberos"	#Valid values are "kerberos" (default) or "password"
password=""			#Note this only needs to be set if authentication type is "password"
mountType="smb"		#The type of file share. Valid types are "afp", "smb", or "dfs".  DFS only supports the "kerberos" authentication method
share=''			#The address of the share you are mounting - if left blank, the script will search for the "SMBHome" attribute in the user record
						#Example Values:
								#SMB Share: smb://server.company.com/share
								#AFP Share: afp://server.company.com/share
								#DFS Path: \\server.company.com\dfsroot\target

# CHECK TO SEE IF A VALUE WERE PASSED IN FOR PARAMETERS $3 THROUGH $9 AND, IF SO, ASSIGN THEM

if [ "$4" != "" ] && [ "$shareUsername" == "" ]; then
    shareUsername=$4
fi

if [ "$5" != "" ] && [ "$authType" == "" ];then
    authType=$5
fi

if [ "$6" != "" ] && [ "$password" == "" ]; then
    password=$6
fi

if [ "$7" != "" ] && [ "$mountType" == "" ]; then
    mountType=$7
fi

if [ "$8" != "" ] && [ "$share" == "" ];then
    share=$8
fi


####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################
loginUsername="$3"
OS=`/usr/bin/defaults read /System/Library/CoreServices/SystemVersion ProductVersion | awk '{print substr($1,1,4)}'`

if [ "$loginUsername" == "" ]; then
	echo "Error:  This script must be run at the login trigger.  Please correct the trigger that is being used to run the policy."
	exit 1
fi

if [ "$authType" == "" ]; then
	echo "Error:  The parameter 'authType' is blank.  Please specify the auth type you would ike to use.  Valid values are 'password' or 'kerberos'"
	exit 1
fi

if [ "$mountType" == "" ]; then
	echo "Error:  The parameter 'mountType' is blank.  Please specify the mount type you would ike to use.  Valid values are 'afp', 'smb', or 'dfs'"
	exit 1
fi

if [ "$mountType" == "dfs" ] && [ "$authType" == "password" ]; then
	echo "Error:  The DFS mount type only supports kerberos authentication."
	exit 1
fi

if [ "$mountType" == "dfs" ] && [ "$share" != "" ]; then
	#Convert the characters in the share over to the proper format
	share="\\\\$share"
fi

if [ "$share" == "" ] && [ "$mountType" != "afp" ]; then
	#If the share parameter is blank, try to read the SMBHome attribute (home directory) from the LDAP server
	echo "Attempting to read SMBHome attribute from user record since the 'share' parameter is blank..."
	share=`/usr/bin/dscl /Search read /Users/$loginUsername SMBHome | head -1 | awk '{print $2}'`
	#If the share is still blank, report an error.
	if [ "$share" == "" ]; then
		echo "Error:  Could not obtain a share from dscl.  Please specify the path to the share you would like to mount."
		exit 1
	else
		if [ "$mountType" == "dfs" ]; then
			#Convert the characters in the share over to the proper format
			share="\\\\$share"
		elif [ "$mountType" == "smb" ]; then
			#Convert the characters in the share over to the proper format
			share="\\\\$share"
			share=`echo $share | sed 's:\\\:/:g'`
			share="smb:$share"
		fi
		echo "Share determined to be: $share."
	fi
fi

#Determine a volume name based on the share
volumeName=`echo "$share" | sed 's:\\\: :g' | sed 's:/: :g' | awk '{print $(NF-0)}'`
echo "Volume name will be created as $volumeName..."
if [ -d "/Volumes/$volumeName" ]; then
	result=`ls -A /Volumes/$volumeName`
	if [ "$result" == "" ]; then
		echo "Removing Empty Directory: /Volumes/$volumeName..."
		rmdir "/Volumes/$volumeName"
	else
		echo "Error: Directory /Volumes/$volumeName is not empty."
		exit 1
	fi
fi


if [ "$authType" == "kerberos" ]; then
	##MOUNT A SHARE WITH KERBEROS AUTHENTICATION
	echo "Attempting to mount $mountType $share using $loginUsername's kerberos ticket..."

	#CREATE A LAUNCH AGENT TO MOUNT THE DRIVES
	/usr/bin/su -l "$loginUsername" -c "/usr/bin/defaults write ~/Library/LaunchAgents/com.jamfsoftware.mapdrive.$volumeName Label -string com.jamfsoftware.mapdrive.$volumeName"
	if [ "$mountType" == "smb" ] || [ "$mountType" == "dfs" ]; then
		if [ "$mountType" == "dfs" ]; then
			#Lookup SMB referral for DFS Share
			#Convert share into format acceptable for smbclient
			share=`echo $share | sed 's:\\\:/:g'`
			#Lookup the DFS SMB referral
			echo "	Looking up SMB referral for DFS Share: $share..."
			share=`/usr/bin/smbclient $share -k -c showconnect | tail -1`
			echo "	Share name referral found to be: $share."
			#Convert referral over to format acceptable for SMB mounting
			share="smb:$share"
		fi
		if [[ "$OS" < "10.6" ]]; then
			#Convert share over to proper format
			share=`echo $share | sed 's#smb://##g'`
			#Write out a launch agent
			/usr/bin/su -l $loginUsername -c "/usr/bin/defaults write ~/Library/LaunchAgents/com.jamfsoftware.mapdrive.$volumeName ProgramArguments -array /bin/sh -c \"/bin/mkdir /Volumes/$volumeName; /sbin/mount_smbfs //$loginUsername@$share /Volumes/$volumeName"\"
		else
			#Apple bug in 10.6 prevents us from using mount_smbfs... if that bug gets fixed, we will revert to it
			
			#Write out a launch agent
			echo "Writing out launch agent to /Users/$loginUsername/Library/LaunchAgents/com.jamfsoftware.mapdrive.$volumeName.plist"
			/usr/bin/su -l "$loginUsername" -c "/usr/bin/defaults write ~/Library/LaunchAgents/com.jamfsoftware.mapdrive.$volumeName ProgramArguments -array /bin/sh -c replaceMe"
			
			#Convert share over to proper format
			share=`echo $share | sed 's#smb://##g'`
			
			#Write in the proper mount command to the plist.  Using sed because defaults write doesn't like quotes or double quotes.
			/usr/bin/su -l "$loginUsername" -c "/usr/bin/plutil -convert xml1 ~/Library/LaunchAgents/com.jamfsoftware.mapdrive.$volumeName.plist"
			/usr/bin/sed "s:replaceMe:/usr/bin/osascript -e \'mount volume (\"smb\://$share\")\':g" "/Users/$loginUsername/Library/LaunchAgents/com.jamfsoftware.mapdrive.$volumeName.plist" > "/private/tmp/com.jamfsoftware.mapdrive.$volumeName.plist.tmp"
			/bin/mv "/private/tmp/com.jamfsoftware.mapdrive.$volumeName.plist.tmp" "/Users/$loginUsername/Library/LaunchAgents/com.jamfsoftware.mapdrive.$volumeName.plist"
			/usr/sbin/chown "$loginUsername":staff "/Users/$loginUsername/Library/LaunchAgents/com.jamfsoftware.mapdrive.$volumeName.plist"
			/bin/chmod 644 "/Users/$loginUsername/Library/LaunchAgents/com.jamfsoftware.mapdrive.$volumeName.plist"
		fi
	else
		#Mount Over AFP Using Kerberos
		
		#Convert share over to proper format
		share=`echo $share | sed 's#afp://##g'`
		
		#WRITE OUT LAUNCH AGENT TO MOUNT THE DRIVES
		/usr/bin/su -l "$loginUsername" -c "/usr/bin/defaults write ~/Library/LaunchAgents/com.jamfsoftware.mapdrive.$volumeName ProgramArguments -array /bin/sh -c \"/bin/mkdir /Volumes/$volumeName \; /sbin/mount_afp -N \'afp://\;AUTH=Client%20Krb%20v2@"$share"\' /Volumes/$volumeName"\"
	fi
	/usr/bin/su -l "$loginUsername" -c "/usr/bin/defaults write ~/Library/LaunchAgents/com.jamfsoftware.mapdrive.$volumeName RunAtLoad -bool true"

	#LOAD THE LAUNCH AGENT
	if /usr/bin/su -l "$loginUsername" -c "/bin/launchctl list | grep com.jamfsoftware.mapdrive.$volumeName"
	then
		echo "Unloading com.jamfsoftware.mapdrive.$volumeName..."
		/usr/bin/su -l "$loginUsername" -c "/bin/launchctl unload ~/Library/LaunchAgents/com.jamfsoftware.mapdrive.$volumeName.plist"
	fi
	echo "Loading com.jamfsoftware.mapdrive.$volumeName..."
	/usr/bin/su -l "$loginUsername" -c "/bin/launchctl load ~/Library/LaunchAgents/com.jamfsoftware.mapdrive.$volumeName.plist"
else
	##MOUNT A SHARE WITH PASSWORD AUTHENTICATION
	if [ "$password" == "" ]; then
		echo "It appears that you are attempting to mount a sharepoint using password authentication, but the password parameter is blank.  Please enter a password for the 'password' parameter of this script."
		exit 1
	fi
	echo "Attempting to mount $mountType://$serverAddress/$share using a password..."
	serverAddress=`echo "$share" | sed 's:/: :g' | awk '{print $2}'`
	share=`echo "$share" | sed 's:/: :g' | awk '{print $3}'`
	/usr/bin/su "$loginUsername" -c "/usr/sbin/jamf mount -server "$serverAddress" -share "$share" -type "$mountType" -username "$shareUsername" -password "$password""
fi

exit 0