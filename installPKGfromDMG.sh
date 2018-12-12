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
#   installPKGfromDMG.sh -- Install a PKG wrapped inside a DMG
#
# SYNOPSIS
#   sudo installPKGfromDMG.sh
#
# DESCRIPTION
#   This script will mount a DMG and install a PKG file wrapped inside.  The script assumes that
#   the DMG has been previously cached to the machine to:
#
#       /Library/Application Support/JAMF/Waiting Room/
#
#   This is the default location that a package will be cached to when selecting the "Cache"
#   option within a policy or Casper Remote.
#
#   To use this script, please follow the following workflow:
#
#   Step 1: Wrap a PKG inside a DMG
#       1.  Open Disk Utility.
#       2.  Navigate to File > New > Disk Image from Folder.
#       3.  Select the PKG and click the Image button.
#       4.  Name the package after the original PKG.
#       5.  Choose a location for the package and then click Save.
#
#   Step 2: Upload the DMG and installPKGfromDMG.sh script to Casper Admin:
#       1.  Open Casper Admin and authenticate.
#       2.  Drag the DMG you created in the previous procedure to the Package pane in Casper Admin.
#       3.  Drag the installPKGfromDMG.sh script to the Package pane in Casper Admin.
#       4.  Save your changes and quit the application.
#
#   Step 3: Create a policy to install the DMG:
#       1.  Log in to the JSS with a web browser.
#       2.  Click the Management tab.
#       3.  Click the Policies link.
#       4.  Click the Create Policy button.
#       5.  Select the Create policy manually option and click Continue.
#       6.  Configure the options on the General and Scope panes as needed.
#       7.  Click the Packages button, and then click the Add Package link.
#       8.  Across from DMG, choose “Cache” from the Action pop-up menu and then click the 
#           "Add Packages" button.
#       9.  Click the Scripts button, and then click the Add Script link.
#       10. Across from the installPKGfromDMG.sh script, choose “Run After” from the Action pop-up menu.
#       11. Enter the name of the original DMG in the Parameter 4 field.            
#       12. Click Save.

#
####################################################################################################
#
# HISTORY
#
#   Version: 1.0
#
#   - Created by Nick Amundsen on July 22, 2011
#   - Modified by Blake Suggett on July 24, 2018
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
#####################################################################################################
#
# HARDCODED VALUES SET HERE
#
# Variables set by Casper - To manually override, remove the comment for the given variable
# targetDrive=""  # Casper will pass this parameter as "Target Drive" if left commented out
# computerName=""  # Casper will pass this parameter as "Computer Name" if left commented out
# userName=""  # Casper will pass this parameter as "User Name" if left commented out. Usernames
#                  can only be passed if the script is triggered at login, logout, or by Self Service

# Variables used for logging
logFile="/private/var/log/jamf.log"

# Variables used by this script.
dmgName=""
forcesuccessflag=""

# CHECK TO SEE IF A VALUE WERE PASSED IN FOR PARAMETERS AND ASSIGN THEM
if [ "$1" != "" ] && [ "$targetDrive" == "" ]; then
    targetDrive="$1"
fi

if [ "$2" != "" ] && [ "$computerName" == "" ]; then
    computerName="$2"
fi

if [ "$3" != "" ] && [ "$userName" == "" ]; then
    userName="$3"
fi

if [ "$4" != "" ] && [ "$dmgName" == "" ]; then
    dmgName="$4"
fi

if [ "$5" != "" ] && [ "$forcesuccessflag" == "" ]; then
    forcesuccessflag="$5"
fi

####################################################################################################
# 
# LOGGING FUNCTION
#
####################################################################################################
log () {
    echo $1
    echo $(date "+%a %b %d %H:%M:%S $HOSTNAME ScriptOutput: ") $1 >> $logFile   
}

####################################################################################################
# 
# VARIABLE VERIFICATION FUNCTION
#
####################################################################################################

log "installPKGfromDMG.sh"

verifyVariable () {
eval variableValue=\$$1
if [ "$variableValue" != "" ]; then
    log "Variable \"$1\" value is set to: $variableValue"
else
    log "Variable \"$1\" is blank.  Please assign a value to the variable."
    exit 1
fi
}

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

# Verify Variables
verifyVariable dmgName

if [ "$forcesuccessflag" = "YES" ]; then
    log "Variable \"forcesuccessflag\" to JSS explicitly declared...: $forcesuccessflag"
elif [ "$forcesuccessflag" != "YES" ]; then
    log "Variable \"forcesuccessflag\" to JSS not explicitly declared, defaulting to NO..."
fi

# Attempt to remove any existing mounts
UnmountDMGNameOnly=`echo $dmgName | sed 's/.dmg*//'`
if [[ -d /Volumes/$UnmountDMGNameOnly ]] ; then
    log "Found an existing mounted DMG, unmounting..."
    hdiutil detach /Volumes/$UnmountDMGNameOnly -force
fi
if [[ -f /Library/Application\ Support/JAMF/Waiting\ Room/$dmgName.shadow ]] ; then
    log "Found an existing shadow file, removing..."
    rm -f /Library/Application\ Support/JAMF/Waiting\ Room/$dmgName.shadow
fi

# Mount the DMG
log "Mounting the DMG $dmgName..."
# mountResult
mountResult=`/usr/bin/hdiutil mount -private -noautoopen -noverify /Library/Application\ Support/JAMF/Waiting\ Room/$dmgName -shadow`
mountResultExitCode=($?)
# mountVolume
mountVolume=`echo "$mountResult" | grep Volumes | awk '{print $3}'`
mountVolumeExitCode=($?)
# mountDevice
mountDevice=`echo "$mountResult" | grep disk | head -1 | awk '{print $1}'`
mountDeviceExitCode=($?)

# Check DMG mount parameters are ok
if [[ $mountResultExitCode == 0 ]] && [[ $mountVolumeExitCode == 0 ]] && [[ $mountDeviceExitCode == 0 ]] ; then
    log "DMG mounted successfully as volume $mountVolume on device $mountDevice."
elif [[ $mountResultExitCode != 0 ]] ; then
    log "$mountResult"
    log "There was an error mounting the DMG. mountResult hdiutil exit code: $mountResultExitCode"
    exit 1
elif [[ $mountVolumeExitCode != 0 ]] ; then
    log "$mountVolume"
    log "There was an error mounting the DMG. mountVolume grep volume exit code: $mountVolumeExitCode"
    exit 1
elif [[ $mountDeviceExitCode != 0 ]] ; then
    log "$mountDevice"
    log "There was an error mounting the DMG. mountDevice grep disk exit code: $mountDeviceExitCode"
    exit 1
fi

# Find the PKG in the DMG
packageName=`ls $mountVolume | grep "pkg"`

# Install the PKG wrapped inside the DMG
log "Installing Package $packageName from mount path $mountVolume..."
/usr/local/jamf/bin/jamf install -path $mountVolume -package $packageName

PKGExitCode=($?)

if [[ "$5" == "YES" ]]; then
    log "PKG exit code was: $PKGExitCode"
    log "Exit code 0 was passed to JSS"
    log "Successfully installed"

    # Unmount the DMG
    echo "Unmounting disk $mountDevice..."
    hdiutil detach "$mountDevice" -force
    UnmountDMGExitCode=($?)

    # If unmount failed attempt unmount using the volumes directory path
    if [ $UnmountDMGExitCode != 0 ] ; then
        log "Unable to unmount using native mountDevice... Attempting volumes unmount..."
        hdiutil detach /Volumes/$UnmountDMGNameOnly -force
        UnmountDMGExitCode=($?)
    fi

    if [ $UnmountDMGExitCode == 0 ] ; then
        log "Successfully unmounted"
    fi

    # Delete the DMG
    /bin/rm /Library/Application\ Support/JAMF/Waiting\ Room/$dmgName

    exit 0

elif [[ "$PKGExitCode" == 0 ]]; then
    log "PKG exit code was: $PKGExitCode"
    log "Exit code $PKGExitCode was passed to JSS"
    log "Successfully installed"

    # Unmount the DMG
    echo "Unmounting disk $mountDevice..."
    hdiutil detach "$mountDevice" -force
    UnmountDMGExitCode=($?)

    # If unmount failed attempt unmount using the volumes directory path
    if [ $UnmountDMGExitCode != 0 ] ; then
        log "Unable to unmount using native mountDevice... Attempting volumes unmount..."
        hdiutil detach /Volumes/$UnmountDMGNameOnly -force
        UnmountDMGExitCode=($?)
    fi

    if [ $UnmountDMGExitCode == 0 ] ; then
        log "Successfully unmounted"
    fi

    # Delete the DMG
    /bin/rm /Library/Application\ Support/JAMF/Waiting\ Room/$dmgName

    exit 0

else
    log "PKG exit code was...: $PKGExitCode"
    log "Exit code $PKGExitCode was passed to JSS"
    log "Failed installation"

    # Unmount the DMG
    echo "Unmounting disk $mountDevice..."
    hdiutil detach "$mountDevice" -force
    UnmountDMGExitCode=($?)

    # If unmount failed attempt unmount using the volumes directory path
    if [ $UnmountDMGExitCode != 0 ] ; then
        log "Unable to unmount using native mountDevice... Attempting volumes unmount..."
        hdiutil detach /Volumes/$UnmountDMGNameOnly -force
        UnmountDMGExitCode=($?)
    fi

    if [ $UnmountDMGExitCode == 0 ] ; then
        log "Successfully unmounted"
    fi

    # Delete the DMG
    /bin/rm /Library/Application\ Support/JAMF/Waiting\ Room/$dmgName

    exit 1
fi
