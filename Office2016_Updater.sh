#!/bin/bash

#################################################
# Microsoft AutoUpdate Script
# Office 2016
# Joshua Harvey | November 2018
# josh[at]macjeezy.com
# GitHub - github.com/therealmacjeezy    
# JAMFnation - therealmacjeezy
#################################################

############ Script Parameters Info #############
## 4 - Word Version (16.16.xxxxxxxx)
## 5 - Excel Version (16.16.xxxxxxxx)
## 6 - PowerPoint Version (16.16.xxxxxxxx)
## 7 - Outlook Version (16.16.xxxxxxxx)
## 8 - OneNote Version (16.16.xxxxxxxx)
##
## If a Parameter is left blank, the script will
## output "Missing <APPNAME> Version" and move on
## to the next app. Each time this script is run,
## it will always check and install (if available)
## updates for Skype for Business, MAU and Remote
## Desktop since they are the same for both versions.
#################################################

# Script Parameters to apply version control with updates
# Word
if [[ ! -z "$4" ]]; then
    /Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate -i -a mswd15 -v "$4"
else
    echo "Missing Word Version"
fi

# Excel
if [[ ! -z "$5" ]]; then
    /Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate -i -a xcel15 -v "$5"
else
    echo "Missing Excel Version"
fi

# PowerPoint
if [[ ! -z "$6" ]]; then
    /Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate -i -a ppt315 -v "$6"
else
    echo "Missing PowerPoint Version"
fi

# Outlook
if [[ ! -z "$7" ]]; then
    /Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate -i -a opim15 -v "$7"
else
    echo "Missing Outlook Version"
fi

# OneNote
if [[ ! -z "$8" ]]; then
    /Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate -i -a onmc15 -v "$8"
else
    echo "Missing OneNote Version"
fi

# Skype for Business, MAU and Remote Desktop
# Uses the same version for both 2019 and 2016 so adding them to the update each time
/Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate -i -a msfb16 msau03 msrd10

exit 0