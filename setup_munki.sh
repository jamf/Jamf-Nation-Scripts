#!/bin/bash
#
# By Piero Giobbi
# 170426
# To configure client with Munki via Jamf
#
# $4 = Set munkiserver (string) - "https://example.com"
# $5 = Set Client Manifest (string) - "MUNKI-EXAMPLE-MANIFEST"
# $6 = Set AppleSoftwareUpdate (boolean) - "TRUE"
#
# Use Check_munki.sh-script to veriy the setup was successful with Jamf


# Set munki server
sudo defaults write /Library/Preferences/ManagedInstalls SoftwareRepoURL "$4"

# Set client manifest
sudo defaults write /Library/Preferences/ManagedInstalls ClientIdentifier "$5"

# Allow Apple Updates
defaults write /Library/Preferences/ManagedInstalls InstallAppleSoftwareUpdates -bool "$6"

# End of Munkisetup, end of fun

exit 0
