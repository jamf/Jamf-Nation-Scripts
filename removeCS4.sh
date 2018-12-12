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
#	removeCS4.sh -- Remove Adobe Create Suite 4.
#
# SYNOPSIS
#	sudo removeCS4.sh
#	sudo removeCS4.sh <mountPoint> <computerName> <currentUsername> <erase>
# DESCRIPTION
#	This script will perform an uninstall of Adobe Creative Suite 4.  The script is designed from
#	a master list of files that are installed by the Adobe CS4 Master Collection.  The script will
#	detect to see if a file exists first, and if the file does exist, it will move the file or
#	directory along with the directory structure for the file into:
#
#		/Library/Application Support/JAMF/RemovedFiles
#
#	Additionally, the script can be modified to completely erase the files that have been moved.
#	Please note that this option should be used with caution, as it will permanently delete any
#	files or directories included in the "files" array within this script.
#	
#	The values supported in the <erase> parameter include:
#
#		"TRUE"
#		"FALSE"
#		"YES"
#		"NO"
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.1
#
#	- Created by Nick Amundsen on April 7th, 2009
#	- Updated by Nick Amundsen on January 21, 2010
#
# 
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################


# HARDCODED VALUES ARE SET HERE
erase=""


# CHECK TO SEE IF A VALUE WAS PASSED FOR $4, AND IF SO, ASSIGN IT
if [ "$4" != "" ] && [ "$erase" == "" ]; then
	erase=$4
fi


####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

files=( '/Applications/Adobe' '/Applications/Adobe Acrobat 9 Pro' '/Applications/Adobe After Effects CS4' '/Applications/Adobe Bridge CS4' '/Applications/Adobe Contribute CS4' '/Applications/Adobe Device Central CS4' '/Applications/Adobe Dreamweaver CS4' '/Applications/Adobe Drive CS4' '/Applications/Adobe Encore CS4' '/Applications/Adobe Extension Manager CS4' '/Applications/Adobe Fireworks CS4' '/Applications/Adobe Flash CS4' '/Applications/Adobe Illustrator CS4' '/Applications/Adobe InDesign CS4' '/Applications/Adobe Media Encoder CS4' '/Applications/Adobe Media Player.app' '/Applications/Adobe OnLocation CS4' '/Applications/Adobe Photoshop CS4' '/Applications/Adobe Premiere Pro CS4' '/Applications/Adobe Soundbooth CS4' '/Applications/Adobe Soundbooth Scores' '/Applications/Utilities/Adobe AIR Application Installer.app' '/Applications/Utilities/Adobe AIR Uninstaller.app' '/Applications/Utilities/Adobe Installers' '/Applications/Utilities/Adobe Utilities.localized' '/Library/Application Support/.Macrovision11.5.0.0 build 56285.uct2' '/Library/Application Support/Adobe' '/Library/Application Support/FLEXnet Publisher' '/Library/Application Support/Macromedia/FlashAuthor.cfg' '/Library/Application Support/Macromedia/FlashPlayerTrust' '/Library/Application Support/Synthetic Aperture Adobe CS4 Bundle' '/Library/ColorSync/Profiles/Profiles' '/Library/ColorSync/Profiles/Recommended' '/Library/Contextual Menu Items/ADFSMenu.plugin' '/Library/Filesystems/AdobeDriveCS4.fs' '/Library/Fonts/ACaslonPro-Bold.otf' '/Library/Fonts/ACaslonPro-BoldItalic.otf' '/Library/Fonts/ACaslonPro-Italic.otf' '/Library/Fonts/ACaslonPro-Regular.otf' '/Library/Fonts/ACaslonPro-Semibold.otf' '/Library/Fonts/ACaslonPro-SemiboldItalic.otf' '/Library/Fonts/AdobeFangsongStd-Regular.otf' '/Library/Fonts/AdobeHeitiStd-Regular.otf' '/Library/Fonts/AdobeKaitiStd-Regular.otf' '/Library/Fonts/AdobeMingStd-Light.otf' '/Library/Fonts/AdobeMyungjoStd-Medium.otf' '/Library/Fonts/AdobeSongStd-Light.otf' '/Library/Fonts/AGaramondPro-Bold.otf' '/Library/Fonts/AGaramondPro-BoldItalic.otf' '/Library/Fonts/AGaramondPro-Italic.otf' '/Library/Fonts/AGaramondPro-Regular.otf' '/Library/Fonts/BellGothicStd-Black.otf' '/Library/Fonts/BellGothicStd-Bold.otf' '/Library/Fonts/BirchStd.otf' '/Library/Fonts/BlackoakStd.otf' '/Library/Fonts/BrushScriptStd.otf' '/Library/Fonts/ChaparralPro-Bold.otf' '/Library/Fonts/ChaparralPro-BoldIt.otf' '/Library/Fonts/ChaparralPro-Italic.otf' '/Library/Fonts/ChaparralPro-Regular.otf' '/Library/Fonts/CharlemagneStd-Bold.otf' '/Library/Fonts/CooperBlackStd-Italic.otf' '/Library/Fonts/CooperBlackStd.otf' '/Library/Fonts/EccentricStd.otf' '/Library/Fonts/GiddyupStd.otf' '/Library/Fonts/HoboStd.otf' '/Library/Fonts/KozGoPro-Bold.otf' '/Library/Fonts/KozGoPro-ExtraLight.otf' '/Library/Fonts/KozGoPro-Heavy.otf' '/Library/Fonts/KozGoPro-Light.otf' '/Library/Fonts/KozGoPro-Medium.otf' '/Library/Fonts/KozGoPro-Regular.otf' '/Library/Fonts/KozMinPro-Bold.otf' '/Library/Fonts/KozMinPro-ExtraLight.otf' '/Library/Fonts/KozMinPro-Heavy.otf' '/Library/Fonts/KozMinPro-Light.otf' '/Library/Fonts/KozMinPro-Medium.otf' '/Library/Fonts/KozMinPro-Regular.otf' '/Library/Fonts/LetterGothicStd-Bold.otf' '/Library/Fonts/LetterGothicStd-BoldSlanted.otf' '/Library/Fonts/LetterGothicStd-Slanted.otf' '/Library/Fonts/LetterGothicStd.otf' '/Library/Fonts/LithosPro-Black.otf' '/Library/Fonts/LithosPro-Regular.otf' '/Library/Fonts/MesquiteStd.otf' '/Library/Fonts/MinionPro-Bold.otf' '/Library/Fonts/MinionPro-BoldCn.otf' '/Library/Fonts/MinionPro-BoldCnIt.otf' '/Library/Fonts/MinionPro-BoldIt.otf' '/Library/Fonts/MinionPro-It.otf' '/Library/Fonts/MinionPro-Medium.otf' '/Library/Fonts/MinionPro-MediumIt.otf' '/Library/Fonts/MinionPro-Regular.otf' '/Library/Fonts/MinionPro-Semibold.otf' '/Library/Fonts/MinionPro-SemiboldIt.otf' '/Library/Fonts/MyriadPro-Bold.otf' '/Library/Fonts/MyriadPro-BoldCond.otf' '/Library/Fonts/MyriadPro-BoldCondIt.otf' '/Library/Fonts/MyriadPro-BoldIt.otf' '/Library/Fonts/MyriadPro-Cond.otf' '/Library/Fonts/MyriadPro-CondIt.otf' '/Library/Fonts/MyriadPro-It.otf' '/Library/Fonts/MyriadPro-Regular.otf' '/Library/Fonts/MyriadPro-Semibold.otf' '/Library/Fonts/MyriadPro-SemiboldIt.otf' '/Library/Fonts/NuevaStd-BoldCond.otf' '/Library/Fonts/NuevaStd-BoldCondItalic.otf' '/Library/Fonts/NuevaStd-Cond.otf' '/Library/Fonts/NuevaStd-CondItalic.otf' '/Library/Fonts/OCRAStd.otf' '/Library/Fonts/OratorStd-Slanted.otf' '/Library/Fonts/OratorStd.otf' '/Library/Fonts/PoplarStd.otf' '/Library/Fonts/PrestigeEliteStd-Bd.otf' '/Library/Fonts/RosewoodStd-Regular.otf' '/Library/Fonts/StencilStd.otf' '/Library/Fonts/TektonPro-Bold.otf' '/Library/Fonts/TektonPro-BoldCond.otf' '/Library/Fonts/TektonPro-BoldExt.otf' '/Library/Fonts/TektonPro-BoldObl.otf' '/Library/Fonts/TrajanPro-Bold.otf' '/Library/Fonts/TrajanPro-Regular.otf' '/Library/Frameworks/Adobe AIR.framework' '/Library/Internet Plug-Ins/AdobePDFViewer.plugin' '/Library/Internet Plug-Ins/npContributeMac.bundle' '/Library/LaunchAgents/com.adobe.CS4ServiceManager.plist' '/Library/LaunchDaemons/com.adobe.versioncueCS4.plist' '/Library/Logs/Adobe' '/Library/PreferencePanes/VersionCueCS4.prefPane' '/Library/Preferences/com.adobe.acrobat.pdfviewer.plist' '/Library/Preferences/com.adobe.AdobeOnlineHelp.plist' '/Library/Preferences/com.adobe.PDFAdminSettings.plist' '/Library/Preferences/com.adobe.versioncueCS4.plist' '/Library/Preferences/com.apple.audio.AggregateDevices.plist' '/Library/Preferences/FLEXnet Publisher' '/Library/Printers/PPD Plugins/AdobePDFPDE900.plugin' '/Library/Printers/PPDs/Contents/Resources/en.lproj/ADPDF9.PPD /Library/Printers/PPDs/Contents/Resources/ja.lproj/ADPDF9J.PPD' '/Library/Printers/PPDs/Contents/Resources/ko.lproj/ADPDF9K.PPD' '/Library/Printers/PPDs/Contents/Resources/zn_CN.lproj/ADPDF9CS.PPD' '/Library/Printers/PPDs/Contents/Resources/zn_TW.lproj/ADPDF9CT.PPD' '/Library/QuickTime/SoundboothScoreCodec.component' '/Library/ScriptingAdditions/Adobe Unit Types.osax' '/Users/Shared/Adobe' '/Users/Shared/Library/Application Support/Adobe' '/private/etc/cups/ppd/AdobePDF9.ppd' '/private/etc/mach_init_per_user.d/com.adobe.versioncueCS4.monitor.plist' '/usr/libexec/cups/backend/pdf900' )

### Create the RemovedFiles Directory if it does not currently exist ###
if [ ! -e '/Library/Application Support/JAMF/RemovedFiles' ]; then
	echo "Creating directory to store moved files..." 
	/bin/mkdir '/Library/Application Support/JAMF/RemovedFiles'
fi


### Loop through the files included in the array and move the files if they are found ###

for (( i = 0; i < ${#files[@]} ; i++ ))
do
	myFile="${files[$i]}"
	if [ -e "$myFile" ]; then
		if [ -f "$myFile" ]; then
			### file object is a true file so create a directory based on it ###
			echo "Moving file: $myFile..."
			myDir=`/usr/bin/dirname "$myFile"`
			/bin/mkdir -p "/Library/Application Support/JAMF/RemovedFiles/$myDir"
			/bin/mv "$myFile" "/Library/Application Support/JAMF/RemovedFiles/$myFile"
		else
			### file object is a directory, so create the directory ###
			echo "Moving directory: $myFile..."
			myDir=`/usr/bin/dirname "$myFile"`
			/bin/mkdir -p "/Library/Application Support/JAMF/RemovedFiles/$myDir"
			/bin/mv "$myFile" "/Library/Application Support/JAMF/RemovedFiles/$myFile"
		fi
	fi
done

### Check to see if the "erase" parameter is set, and if so, delete the files that were moved ###

case $erase in "true" | "TRUE" | "yes" | "YES")
	echo "Emptying directory: /Library/Application Support/JAMF/RemovedFiles..."
	/bin/rm -rf "/Library/Application Support/JAMF/RemovedFiles";;
	*)
esac

exit 0;
