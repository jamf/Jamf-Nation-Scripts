#!/bin/bash
# Meza Hsu
# May 13, 2016
# Based on https://support.office.com article titled: Troubleshoot Office 2011 for Mac issues by completely uninstalling before you reinstall

# Attempt to Quit Office Applications prior to removal
osascript -e 'tell application "Microsoft Database Daemon" to quit'
osascript -e 'tell application "Microsoft AU Daemon" to quit'
osascript -e 'tell application "Office365Service" to quit'
osascript -e 'tell application "Microsoft Excel.app" to quit without saving'
osascript -e 'tell application "Microsoft PowerPoint.app" to quit without saving'
osascript -e 'tell application "Microsoft Word.app" to quit without saving'
osascript -e 'tell application "Microsoft Outlook.app" to quit'

# Step 1: Remove the Microsoft Office 2011 folder
/bin/rm -R /Applications/Microsoft\ Office\ 2011/

# Step 2: Remove preference and license files and Office folder
/bin/rm /Users/$3/Library/Preferences/com.microsoft.Excel.plist 
/bin/rm /Users/$3/Library/Preferences/com.microsoft.office.plist 
/bin/rm /Users/$3/Library/Preferences/com.microsoft.office.setupassistant.plist 
/bin/rm /Users/$3/Library/Preferences/com.microsoft.outlook.databasedaemon.plist 
/bin/rm /Users/$3/Library/Preferences/com.microsoft.outlook.office_reminders.plist 
/bin/rm /Users/$3/Library/Preferences/com.microsoft.Outlook.plist 
/bin/rm /Users/$3/Library/Preferences/com.microsoft.PowerPoint.plist 
/bin/rm /Users/$3/Library/Preferences/com.microsoft.Word.plist
/bin/rm /Users/$3/Library/Preferences/ByHost/com.microsoft.*
/bin/rm /Library/LaunchDaemons/com.microsoft.office.licensing.helper.plist 
/bin/rm /Library/Preferences/com.microsoft.office.licensing.plist 
/bin/rm /Library/PrivilegedHelperTools/com.microsoft.office.licensing.helper 

# Step 3: Remove Microsoft folders and Office 2011 files
/bin/rm -R /Library/Application\ Support/Microsoft/
/bin/rm -R /Library/Fonts/Microsoft/
/bin/rm /Library/Receipts/Office2011_*

# Step 4: Rename and optionally remove Microsoft User Data folder
# perform this step at your own risk of losing user data
# /bin/rm -R /Users/$3/Documents/Microsoft\ User\ Data/

# Step 5: Empty Trash and restart
# no need

# Step 6: Remove Office application icons
/usr/local/bin/dockutil --remove 'Microsoft Word' --allhomes
/usr/local/bin/dockutil --remove 'Microsoft Outlook' --allhomes
/usr/local/bin/dockutil --remove 'Microsoft PowerPoint' --allhomes
/usr/local/bin/dockutil --remove 'Microsoft Excel' --allhomes

# Misc. Remove Related Legacy Apps, Automator Actions & Sharepoint Plug-In
rm -R '/Applications/Microsoft Communicator.app/'
rm -R '/Applications/Microsoft Messenger.app/'
rm -R '/Applications/Remote Desktop Connection.app/'
rm -R /Library/Automator/*Excel*
rm -R /Library/Automator/*Office*
rm -R /Library/Automator/*Outlook*
rm -R /Library/Automator/*PowerPoint*
rm -R /Library/Automator/*Word*
rm -R /Library/Automator/*Workbook*
rm -R '/Library/Automator/Get Parent Presentations of Slides.action'
rm -R '/Library/Automator/Set Document Settings.action'
rm -R /Library/Internet\ Plug-Ins/SharePoint*

exit 0