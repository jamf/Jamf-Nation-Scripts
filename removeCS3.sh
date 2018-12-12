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
#	removeCS3.sh -- Remove Adobe Create Suite 3.
#
# SYNOPSIS
#	sudo removeCS3.sh
#	sudo removeCS3.sh <mountPoint> <computerName> <currentUsername> <erase>
#
# DESCRIPTION
#	This script will perform an uninstall of Adobe Creative Suite 3.  The script is designed from
#	a master list of files that are installed by the Adobe CS3 Master Collection.  The script will
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

files=( '/Applications/Adobe Acrobat 8 Professional' '/Applications/Adobe After Effects CS3' '/Applications/Adobe Bridge CS3' '/Applications/Adobe Contribute CS3' '/Applications/Adobe Device Central CS3' '/Applications/Adobe Dreamweaver CS3' '/Applications/Adobe Encore CS3' '/Applications/Adobe Extension Manager' '/Applications/Adobe Fireworks CS3' '/Applications/Adobe Flash CS3' '/Applications/Adobe Flash CS3 Video Encoder' '/Applications/Adobe Help Viewer 1.0.app' '/Applications/Adobe Help Viewer 1.1.app' '/Applications/Adobe Illustrator CS3' '/Applications/Adobe InDesign CS3' '/Applications/Adobe Photoshop CS3' '/Applications/Adobe Premiere Pro CS3' '/Applications/Adobe Soundbooth CS3' '/Applications/Adobe Soundbooth Scores' '/Applications/Adobe Stock Photos CS3' '/Applications/Utilities/Adobe Installers' '/Applications/Utilities/Adobe Utilities.localized' '/Library/Application Support/Adobe' '/Library/Application Support/FLEXnet Publisher' '/Library/Application Support/Macromedia/FlashAuthor.cfg' '/Library/Application Support/Macromedia/FlashPlayerTrust' '/Library/Application Support/Synthetic Aperture Adobe Bundle' '/Library/Fonts/ACaslonPro-Bold.otf' '/Library/Fonts/ACaslonPro-BoldItalic.otf' '/Library/Fonts/ACaslonPro-Italic.otf' '/Library/Fonts/ACaslonPro-Regular.otf' '/Library/Fonts/ACaslonPro-Semibold.otf' '/Library/Fonts/ACaslonPro-SemiboldItalic.otf' '/Library/Fonts/AGaramondPro-Bold.otf' '/Library/Fonts/AGaramondPro-BoldItalic.otf' '/Library/Fonts/AGaramondPro-Italic.otf' '/Library/Fonts/AGaramondPro-Regular.otf' '/Library/Fonts/ArnoPro-Bold.otf' '/Library/Fonts/ArnoPro-BoldCaption.otf' '/Library/Fonts/ArnoPro-BoldDisplay.otf' '/Library/Fonts/ArnoPro-BoldItalic.otf' '/Library/Fonts/ArnoPro-BoldItalicCaption.otf' '/Library/Fonts/ArnoPro-BoldItalicDisplay.otf' '/Library/Fonts/ArnoPro-BoldItalicSmText.otf' '/Library/Fonts/ArnoPro-BoldItalicSubhead.otf' '/Library/Fonts/ArnoPro-BoldSmText.otf' '/Library/Fonts/ArnoPro-BoldSubhead.otf' '/Library/Fonts/ArnoPro-Caption.otf' '/Library/Fonts/ArnoPro-Display.otf' '/Library/Fonts/ArnoPro-Italic.otf' '/Library/Fonts/ArnoPro-ItalicCaption.otf' '/Library/Fonts/ArnoPro-ItalicDisplay.otf' '/Library/Fonts/ArnoPro-ItalicSmText.otf' '/Library/Fonts/ArnoPro-ItalicSubhead.otf' '/Library/Fonts/ArnoPro-LightDisplay.otf' '/Library/Fonts/ArnoPro-LightItalicDisplay.otf' '/Library/Fonts/ArnoPro-Regular.otf' '/Library/Fonts/ArnoPro-Smbd.otf' '/Library/Fonts/ArnoPro-SmbdCaption.otf' '/Library/Fonts/ArnoPro-SmbdDisplay.otf' '/Library/Fonts/ArnoPro-SmbdItalic.otf' '/Library/Fonts/ArnoPro-SmbdItalicCaption.otf' '/Library/Fonts/ArnoPro-SmbdItalicDisplay.otf' '/Library/Fonts/ArnoPro-SmbdItalicSmText.otf' '/Library/Fonts/ArnoPro-SmbdItalicSubhead.otf' '/Library/Fonts/ArnoPro-SmbdSmText.otf' '/Library/Fonts/ArnoPro-SmbdSubhead.otf' '/Library/Fonts/ArnoPro-SmText.otf' '/Library/Fonts/ArnoPro-Subhead.otf' '/Library/Fonts/BellGothicStd-Black.otf' '/Library/Fonts/BellGothicStd-Bold.otf' '/Library/Fonts/BickhamScriptPro-Bold.otf' '/Library/Fonts/BickhamScriptPro-Regular.otf' '/Library/Fonts/BickhamScriptPro-Semibold.otf' '/Library/Fonts/BirchStd.otf' '/Library/Fonts/BlackoakStd.otf' '/Library/Fonts/BrushScriptStd.otf' '/Library/Fonts/ChaparralPro-Bold.otf' '/Library/Fonts/ChaparralPro-BoldIt.otf' '/Library/Fonts/ChaparralPro-Italic.otf' '/Library/Fonts/ChaparralPro-Regular.otf' '/Library/Fonts/CharlemagneStd-Bold.otf' '/Library/Fonts/CooperBlackStd-Italic.otf' '/Library/Fonts/CooperBlackStd.otf' '/Library/Fonts/EccentricStd.otf' '/Library/Fonts/GaramondPremrPro-It.otf' '/Library/Fonts/GaramondPremrPro-Smbd.otf' '/Library/Fonts/GaramondPremrPro-SmbdIt.otf' '/Library/Fonts/GaramondPremrPro.otf' '/Library/Fonts/GiddyupStd.otf' '/Library/Fonts/HoboStd.otf' '/Library/Fonts/KozGoPro-Bold.otf' '/Library/Fonts/KozGoPro-ExtraLight.otf' '/Library/Fonts/KozGoPro-Heavy.otf' '/Library/Fonts/KozGoPro-Light.otf' '/Library/Fonts/KozGoPro-Medium.otf' '/Library/Fonts/KozGoPro-Regular.otf' '/Library/Fonts/KozMinPro-Bold.otf' '/Library/Fonts/KozMinPro-ExtraLight.otf' '/Library/Fonts/KozMinPro-Heavy.otf' '/Library/Fonts/KozMinPro-Light.otf' '/Library/Fonts/KozMinPro-Medium.otf' '/Library/Fonts/KozMinPro-Regular.otf' '/Library/Fonts/LetterGothicStd-Bold.otf' '/Library/Fonts/LetterGothicStd-BoldSlanted.otf' '/Library/Fonts/LetterGothicStd-Slanted.otf' '/Library/Fonts/LetterGothicStd.otf' '/Library/Fonts/LithosPro-Black.otf' '/Library/Fonts/LithosPro-Regular.otf' '/Library/Fonts/MesquiteStd.otf' '/Library/Fonts/MinionPro-Bold.otf' '/Library/Fonts/MinionPro-BoldCn.otf' '/Library/Fonts/MinionPro-BoldCnIt.otf' '/Library/Fonts/MinionPro-BoldIt.otf' '/Library/Fonts/MinionPro-It.otf' '/Library/Fonts/MinionPro-Medium.otf' '/Library/Fonts/MinionPro-MediumIt.otf' '/Library/Fonts/MinionPro-Regular.otf' '/Library/Fonts/MinionPro-Semibold.otf' '/Library/Fonts/MinionPro-SemiboldIt.otf' '/Library/Fonts/MyriadPro-Bold.otf' '/Library/Fonts/MyriadPro-BoldCond.otf' '/Library/Fonts/MyriadPro-BoldCondIt.otf' '/Library/Fonts/MyriadPro-BoldIt.otf' '/Library/Fonts/MyriadPro-Cond.otf' '/Library/Fonts/MyriadPro-CondIt.otf' '/Library/Fonts/MyriadPro-It.otf' '/Library/Fonts/MyriadPro-Regular.otf' '/Library/Fonts/MyriadPro-Semibold.otf' '/Library/Fonts/MyriadPro-SemiboldIt.otf' '/Library/Fonts/NuevaStd-BoldCond.otf' '/Library/Fonts/NuevaStd-BoldCondItalic.otf' '/Library/Fonts/NuevaStd-Cond.otf' '/Library/Fonts/NuevaStd-CondItalic.otf' '/Library/Fonts/OCRAStd.otf' '/Library/Fonts/OratorStd-Slanted.otf' '/Library/Fonts/OratorStd.otf' '/Library/Fonts/PoplarStd.otf' '/Library/Fonts/PrestigeEliteStd-Bd.otf' '/Library/Fonts/RosewoodStd-Regular.otf' '/Library/Fonts/StencilStd.otf' '/Library/Fonts/TektonPro-Bold.otf' '/Library/Fonts/TektonPro-BoldCond.otf' '/Library/Fonts/TektonPro-BoldExt.otf' '/Library/Fonts/TektonPro-BoldObl.otf' '/Library/Fonts/TrajanPro-Bold.otf' '/Library/Fonts/TrajanPro-Regular.otf' '/Library/Internet Plug-Ins/AdobePDFViewer.plugin' '/Library/LaunchDaemons/com.adobe.versioncueCS3.plist' '/Library/Logs/Adobe' '/Library/PreferencePanes/VersionCueCS3.prefPane' '/Library/Preferences/com.adobe.acrobat.pdfviewer.plist' '/Library/Preferences/com.adobe.PDFAdminSettings.plist' '/Library/Preferences/com.Adobe.Premiere Pro.3.0.plist' '/Library/Preferences/com.adobe.versioncueCS3.plist' '/Library/Preferences/FLEXnet Publisher' '/Library/Printers/PPD Plugins/AdobePDFPDE800.plugin' '/Library/Printers/PPDs/Contents/Resources/en.lproj/ADPDF8.PPD' '/Library/Printers/PPDs/Contents/Resources/ja.lproj/ADPDF8J.PPD' '/Library/Printers/PPDs/Contents/Resources/ko.lproj/ADPDF8K.PPD' '/Library/Printers/PPDs/Contents/Resources/zh_CN.lproj/ADPDF8CS.PPD' '/Library/Printers/PPDs/Contents/Resources/zh_TW.lproj/ADPDF8CT.PPD' '/Library/QuickTime/FLV.component' '/Library/QuickTime/SoundboothScoreCodec.component' '/private/etc/cups/ppd/AdobePDF8.ppd' '/private/etc/mach_init_per_user.d/com.adobe.versioncueCS3.monitor.plist' '/usr/libexec/cups/backend/pdf800' )

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
