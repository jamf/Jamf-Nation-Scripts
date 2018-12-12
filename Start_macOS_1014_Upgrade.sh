#!/bin/bash

#################################################
# macOS 10.14 Updater
# Policy - Self Service
# Joshua Harvey | August 2018
# josh[at]macjeezy.com
# GitHub - github.com/therealmacjeezy    
# JAMFnation - therealmacjeezy
#################################################

####### Supported macOS Versions ##########################################################
# macOS 10.11.x, macOS 10.12.x, macOS 10.13.x
####### Script Overview ###################################################################
# This script will setup a plist for an authenticated reboot, check the disk type for the 
# computer, then run the startosinstall binary. Before the
# computer restarts, it will kill self service which is required due to the startosinstall
# performing a soft restart and is not able to force quit other applications
#
# NOTE: The Install macOS Mojave.app must be in the Applications folder before this script
# is ran.
###########################################################################################

# Pulls the current logged in user and their UID
currUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}')
currUserUID=$(id -u "$currUser")

fvPass=$(
# Prompts the user to input their FileVault password using Applescript. This password is used for a one time authenticated reboot. Once the installation is started, the file that was used to reboot the system is deleted.
/bin/launchctl asuser "$currUserUID" sudo -iu "$currUser" /usr/bin/osascript <<APPLESCRIPT

set validatedPass to false

repeat while (validatedPass = false)
-- Prompt the user to enter their filevault password
display dialog "Enter your Filevault 2 Password to allow a one time authenticated reboot, which is used to start the macOS 10.14 upgrade" with icon file "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:FileVaultIcon.icns" default answer "" buttons {"Continue"} with text and hidden answer default button "Continue"

set fvPass to (text returned of result)

display dialog "Re-enter the Filevault 2 Password to verifed it was entered correctly" with text and hidden answer buttons {"Continue"} with icon file "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:FileVaultIcon.icns" default answer "" default button "Continue"

if text returned of result is equal to fvPass then
	set validatedPass to true
	fvPass
else
	display dialog "The passwords you have entered do not match. Please enter matching passwords." with title "FileVault Password Validation Failed" buttons {"Re-Enter Password"} default button "Re-Enter Password" with icon file messageIcon
end if
end repeat

APPLESCRIPT
)

# Sets the comptuer up for an authenticated restart using a temp account
/usr/bin/fdesetup authrestart -delayminutes -1 -verbose -inputplist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Username</key>
	<string>"$currUser"</string>
	<key>Password</key>
	<string>"$fvPass"</string>
</dict>
</plist>
EOF

# Runs the startosinstall binary to start the upgrade
"/Applications/Install macOS Mojave.app/Contents/Resources/startosinstall" --applicationpath "/Applications/Install macOS Mojave.app" --rebootdelay 0 --nointeraction --agreetolicense

# Pulls the current user
currUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}')
currUserUID=$(id -u "$currUser")

# Kills self service to allow the installer to continue with the update
/bin/launchctl asuser "$currUserUID" sudo -iu "$currUser" killall "Self Service"

# Exits the script
exit 0