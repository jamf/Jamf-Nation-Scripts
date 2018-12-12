#!/bin/sh

##########################################
# Encrypt External Volume 				 
# Josh Harvey | June 2017				 
# josh[at]macjeezy.com 				 	 
# GitHub - github.com/therealmacjeezy    
# JAMFnation - therealmacjeezy			 
##########################################

####### CocoaDialog Required ######################################################
# This script requires CocoaDialog to be installed and the location added to the 
# variable after this section. If you do not have CocoaDialog installed, you can
# comment out the Progress section in each of the functions that use it. If you opt
# to do this, I can not guarentee the script will function as intended and there
# will not be a progress prompt for the user unless you manually add another one
###### AppleScript Icons #########################################################
# This script uses the default icons for AppleScript. If you want to use your own
# be sure to replace them with either alias paths or POSIX paths
##################### ISSUES / USAGE #############################################
# If you have any issues or questions please feel free to contact  	    
# using the information in the header of this script.                   
#																		
# Also, Please give me credit and let me know if you are going to use  
# this script. I would love to know how it works out and if you find    
# it helpful.  														    
##################################################################################

#### Variables ###################################################################
# Variable for the cocoaDialog path
# Example: /path/to/CocoaDialog.app/Contents/MacOS/CocoaDialog
cocoaD=""
# Variable for the log. This will need to be the full path and the name for the 
# log file.
# Example: /path/to/log/volumeLog.txt
logPath=""
##################################################################################

#=========== Script Funtions ==========#
volumeChecks() {
	#Finds the disk number
	diskNumber=`diskutil info "$pickVolume" | grep "Part of Whole:" | awk {'print $4'}`
	#Finds the volume name
	volumeName=`diskutil info "$pickVolume" | grep "Volume Name" | sed 's/.*://g' | awk '{$1=$1};1'`
	#Finds the disk location (Internal / External)
	deviceLocation=`diskutil info "$pickVolume" | grep "Device Location:" | awk {'print $3'}`
	#Finds the parition map of the volume
	partitionScheme=`diskutil info "$diskNumber" | grep "Content (IOContent)" | awk {'print $3'}`
	#Checks to see if the volume is already encrypted
	encryptionCheck=`diskutil info "$diskNumber" | grep "Encrypted" | sed 's/.*://g' | awk '{$1=$1};1'`
	#Finds the Logical Volume Group UUID
	LVGuuid=`diskutil info "$pickVolume" | grep "LVG UUID:" | sed 's/.*://g' | awk '{$1=$1};1'`
	#Finds the Logival Volume UUID
	LVuuid=`diskutil info "$pickVolume" | grep "LV UUID:" | sed 's/.*://g' | awk '{$1=$1};1'`
	#Finds the capacity of the volume
	diskSize=`diskutil info "$pickVolume" | grep "Disk Size:" | sed 's/.*://g' | awk '{$1=$1};1' | awk {'print $1'}`
}

renameVolume() {
#Sets a variable from the new name the user enters
newName=`/usr/bin/osascript <<'APPLESCRIPT'
set renameOption to display dialog "Would you like to rename the volume?" with title "Rename Volume?" buttons {"Yes - Rename", "No"} default button "No" with icon 2

if button returned of renameOption is "No" then return

if button returned of renameOption is "Yes - Rename" then
	set updatedName to display dialog "Enter the new name for the volume:" with title "Enter Name" default answer "" buttons {"Rename"} with icon 2
	set selectedName to text returned of updatedName
	selectedName
end if
APPLESCRIPT`
}

encryptedVolume() {
#Prompt that will appear asking the user to select an option if the volume is encrypted
encryptAgain=`/usr/bin/osascript <<'APPLESCRIPT'
set encryptionFound to display dialog "The volume you have selected is already encrypted. 

If you have forgotten the passphrase for the volume, select \"Exit\" and contact your IT Admin to have the passphrase pulled from the JSS.

If you would like to change the passphrase and know the current passphrase, select \"Change Passphrase\"

If you would like to erase the volume and encrypt it again select \"Erase Volume\"
" with title "Encryption Exists" buttons {"Exit", "Change Passphrase", "Erase Volume"} default button "Exit" with icon file "Library:VA:passwordsuccess_icon.png"

if button returned of encryptionFound is "Erase Volume" then
	set eraseVolume to "Yes"
end if

if button returned of encryptionFound is "Change Passphrase" then
	set eraseVolume to "Change"
end if

if button returned of encryptionFound is "Exit" then
	set eraseVolume to "Exit"
end if

eraseVolume
APPLESCRIPT`

#If statements to handle the user's selection
if [[ "$encryptAgain" == "Yes" ]];
	then
		verifyErase
		echo "Erasing Encrypted Volume.."
		eraseCS
		startEncryption
elif [[ "$encryptAgain" == "Change" ]];
	then
		echo "Changing Passphrase"
		changePassphrase
elif [[ "$encryptAgain" == "Exit" ]];
	then
		echo "$encryptAgain"
		exit 0
fi
}

changePassphrase() {
#Captures the current passphrase
oldPass=`/usr/bin/osascript <<'APPLESCRIPT'
set oldPassword to display dialog "Please the current passphrase used to unlock the volume:" default answer "" with title "Current Encryption Passphrase" buttons {"Continue"} default button 1 with icon 1 with text and hidden answer
set oldPass to (text returned of result)
APPLESCRIPT`

#Captures and validates the new password
newPass=`/usr/bin/osascript <<'APPLESCRIPT'
--Verifies that the password for FileVault is more than 8 characters
set repeatPrompt to true
--Repeat statement to check for 8 characters and repeat if not found
repeat while (repeatPrompt = true)
	
	set newPassword to display dialog "Please enter a new passphrase to use for encryption:" default answer "" with title "New Encryption Passphrase" buttons {"Use Passphrase"} default button 1 with icon 1 with text and hidden answer
	set userPass to (text returned of result)
	
	--if statement to check the input length
	if length of (text returned of newPassword) is less than 8 then
		display dialog "Please enter a passphrase that is 8 characters or longer" buttons {"Re-Enter Passphrase"} default button "Re-Enter Passphrase" with icon 1
	else if length of (text returned of newPassword) is greater than 7 then
		set verifyPassword to display dialog "Please Re-Enter Your New Passphrase:" default answer "" with title "Verify New Encryption Passphrase" buttons {"Continue"} default button 1 with icon 1 with text and hidden answer
		--if statement to verify that the password has been entered correctly and matches
		if text returned of result is equal to userPass then
			set repeatPrompt to false
			display dialog "Your new passphrase matches and has been applied." with title "Encryption Passphrase Updated Successfully" buttons {"Continue"} default button "Continue" with icon file 1 giving up after 5
			userPass
		else
			display dialog "The passphrases you have entered do not match. Please enter matching passphrases." with title "Encryption Passphrase Validation Failed" buttons {"Re-Enter Passphrase"} default button "Re-Enter Passphrase" with icon stop
		end if
	end if
end repeat
APPLESCRIPT`

#Takes the password and encodes it with base64
pMask=`echo "$newPass" | base64`

### Progress Dialog ###
#//Create pipe
rm -f /tmp/hpipe
mkfifo /tmp/hpipe

#//Create a job that takes the input from the pipe
"$cocoaD" progressbar \
--indeterminate --title "Changing Passphrase" \
--text "Please wait..." < /tmp/hpipe &

#//Sends text through the pipe to be displayed
exec 3<> /tmp/hpipe
echo -n "Changing Passphrase for \""$volumeName" ("$diskSize" GB)\" ... Please Wait ..." >&3

#//Erase volume and apply new parition scheme
diskutil cs changeVolumePassphrase "$LVuuid" -oldpassphrase "$oldPass" -newpassphrase "$newPass"

#//Stop progress bar
exec 3>&-

#//Wait for background jobs to complete then remove the pipe
wait
rm -f /tmp/hpipe

encryptionLog

/usr/bin/osascript <<'APPLESCRIPT'
	display dialog "The volume is now encrypted using the new passphrase you selected. A copy of the new passphrase has been uploaded to the JSS in the event you need to recover it." with title "Passphrase Change Completed" buttons {"Continue"} default button "Continue" with icon 1 giving up after 10
APPLESCRIPT

exit 0
}

#Function to erase a core storage volume
eraseCS() {
#//Create pipe
rm -f /tmp/hpipe
mkfifo /tmp/hpipe

#//Create a job that takes the input from the pipe
"$cocoaD" progressbar \
--indeterminate --title "Erasing Volume" \
--text "Please wait..." < /tmp/hpipe &

#//Sends text through the pipe to be displayed
exec 3<> /tmp/hpipe
echo -n "Erasing Volume: \""$volumeName" ("$diskSize" GB)\" ... Please Wait ..." >&3

#//Erase volume and apply new parition scheme
diskutil cs delete "$LVGuuid"
diskutil rename disk2s2 "$volumeName"

#//Stop progress bar
exec 3>&-

#//Wait for background jobs to complete then remove the pipe
wait
rm -f /tmp/hpipe

#Prompt to inform the user the volume has been been erased
/usr/bin/osascript <<'APPLESCRIPT'
	display dialog "The volume has been successfully erased. Starting Encryption Process." with title "Erase Complete" buttons {"Ok"} default button "Ok" with icon 1 giving up after 10
APPLESCRIPT
}

#Function to erase a non core storage volume
eraseVolume() {
#//Create pipe
rm -f /tmp/hpipe
mkfifo /tmp/hpipe

#//Create a job that takes the input from the pipe
"$cocoaD" progressbar \
--indeterminate --title "Erasing Volume" \
--text "Please wait..." < /tmp/hpipe &

#//Sends text through the pipe to be displayed
exec 3<> /tmp/hpipe
echo -n "Erasing Volume: \""$volumeName" ("$diskSize" GB)\" ... Please Wait ..." >&3

#//Erase volume and apply new parition scheme
diskutil eraseDisk jhfs+ "$volumeName" GPT "$diskNumber"

#//Stop progress bar
exec 3>&-

#//Wait for background jobs to complete then remove the pipe
wait
rm -f /tmp/hpipe

#Prompt to infom the user of the status
/usr/bin/osascript <<'APPLESCRIPT'
	display dialog "The volume has been successfully erased. Starting Encryption Process." with title "Erase Complete" buttons {"Ok"} default button "Ok" with icon 1 giving up after 10
APPLESCRIPT

#Starts the encryption function
startEncryption
}

#Function to capture the password for the volume and validate it after its entered
createPassphrase() {
/usr/bin/osascript <<'APPLESCRIPT'
--Verifies that the password for FileVault is more than 8 characters
set repeatPrompt to true
--Repeat statement to check for 8 characters and repeat if not found
repeat while (repeatPrompt = true)
	
	set newPassword to display dialog "Please enter a passphrase to use for encryption:" default answer "" with title "Encryption Passphrase" buttons {"Use Passphrase"} default button 1 with icon 1 with text and hidden answer
	set userPass to (text returned of result)
	
	--if statement to check the input length
	if length of (text returned of newPassword) is less than 8 then
		display dialog "Please use a passphrase that is 8 characters or longer" buttons {"Re-Enter Passphrase"} default button "Re-Enter Passphrase" with icon 1
	else if length of (text returned of newPassword) is greater than 7 then
		set verifyPassword to display dialog "Please Re-Enter Your Passphrase:" default answer "" with title "Verify Encryption Passphrase" buttons {"Continue"} default button 1 with icon 1 with text and hidden answer
		--if statement to verify that the password has been entered correctly and matches
		if text returned of result is equal to userPass then
			set repeatPrompt to false
			display dialog "Your Passphrase Has Been Verified and Accepted." with title "Encryption Passphrase Validation Successful" buttons {"Continue"} default button "Continue" with icon 1 giving up after 5
			userPass
		else
			display dialog "The passphrases you have entered do not match. Please enter matching passphrases." with title "Encryption Passphrase Validation Failed" buttons {"Re-Enter Passphrase"} default button "Re-Enter Passphrase" with icon stop
		end if
	end if
end repeat
APPLESCRIPT
}

#Function to start encryption
startEncryption() {
#Variable that calls the create passphrase function
userPassphrase=`createPassphrase`
#Variable to encode the passphrase with base64
pMask=`echo "$userPassphrase" | base64`

#//Create pipe
rm -f /tmp/hpipe
mkfifo /tmp/hpipe

#//Create a job that takes the input from the pipe
"$cocoaD" progressbar \
--indeterminate --title "Encrypting Volume" \
--text "Please wait..." < /tmp/hpipe &

#//Sends text through the pipe to be displayed
exec 3<> /tmp/hpipe
echo -n "Encrypting \""$volumeName" ("$diskSize" GB)\" ... This may take awhile ..." >&3

#//Apply new parition scheme
diskutil cs convert "$pickVolume" -passphrase "$userPassphrase"

#//Stop progress bar
exec 3>&-

#//Wait for background jobs to complete then remove the pipe
wait
rm -f /tmp/hpipe

#Starts function to log the passphrase and upload it to the JSS into the extension attribute
encryptionLog
#Starts the function to inform the user the encryption is finished
encryptionFinished
}

#Function to verify the next step
verifyStart() {
userVerify=`/usr/bin/osascript <<'APPLESCRIPT'
set askUser to display dialog "The encryption process is about to begin in 10 seconds. If you would like to quit before it begins, select \"Exit\" now." buttons {"Exit", "Continue"} default button "Exit" giving up after 10 with title "Starting Encryption Soon.."

if button returned of askUser is "Exit" then
	set userStop to yes
	userStop
end if

APPLESCRIPT`
echo "$userVerify"

if [[ "$userVerify" == "yes" ]];
	then
		echo "Quitting.."
		exit 0
fi
}

#Function to verify the erase
verifyErase() {
userVerify=`/usr/bin/osascript <<'APPLESCRIPT'
set askUser to display dialog "The erase process is about to begin in 10 seconds. If you would like to quit before it begins, select \"Exit\" now." buttons {"Exit", "Continue"} default button "Exit" giving up after 10 with title "Starting Erase Soon.."

if button returned of askUser is "Exit" then
	set userStop to yes
	userStop
end if

APPLESCRIPT`
echo "$userVerify"

if [[ "$userVerify" == "yes" ]];
	then
		echo "Quitting.."
		exit 0
fi
}

#Function to inform the user the encryption is complete
encryptionFinished() {
/usr/bin/osascript <<'APPLESCRIPT'
	display dialog "The volume is now encrypted using the passphrase you selected. A copy of the passphrase has been uploaded to the JSS in the event you need to recover it." with title "Encryption Completed" buttons {"Continue"} default button "Continue" with icon 1 giving up after 10
APPLESCRIPT
exit 0
}

#Function to create and log the passphrase
encryptionLog() {
#Pulls the current user that is logged in
currentUser=`who | grep "console" | cut -d" " -f1`
#Pulls the current date
currentDate=`date`
#Creates the variable for the log
logItems=`echo "$currentDate $currentUser \"$volumeName\" $pMask"`
#Appends the variable set above to the log on the next available line
echo "$logItems" >> "$logPath"
#Hides the log file
chflags hidden "$logPath"
#Updates the inventory to the JSS
#Uncomment to upload to the JSS
#sudo jamf recon
}

#======== Volume Selection Section ========#
pickVolume=`/usr/bin/osascript <<'APPLESCRIPT'
--Sets the variable to loop until volume is verified by the user
set volumeVerified to false

repeat while volumeVerified is false
-- Returns the volumes that are currently mounted
-- If you want to exclude the startup volume, replace "VOLUMENAME" in the grep command
-- do shell script "ls /Volumes | grep -v \"VOLUMENAME\""
do shell script "ls /Volumes"
-- Creates a list from the ls command above 
set listVolumes to the paragraphs of result
-- Creates a prompt for the user to select a volume from list created above
set chooseVolume to (choose from list listVolumes with prompt "Select the external drive to use:" OK button name "Select Volume" cancel button name "Exit" without empty selection allowed)
-- Quits if the user selects cancel
if chooseVolume is false then return
-- Sets the selected volume to the POSIX path
set selectedVolume to "/Volumes/" & chooseVolume & "/"
	
--Verifies the drive selected is correct
set verifyVolume to display dialog "You have selected: 

	/Volumes/" & chooseVolume & "

Is this correct?" with title "Verify Volume" buttons {"Continue", "Go Back"} with icon file 1
	
	if button returned of verifyVolume is "Continue" then
		set volumeVerified to true
	end if
end repeat

selectedVolume
APPLESCRIPT`
#=========================================#

#//Verifies a volume has been selected before continuing. If a volume has been selected, it will run the function to fill the variables that may be used throughout the script
if [[ -z "$pickVolume" ]];
	then
		echo "No volume selected..exiting."
		exit 0
else
	volumeChecks
	renameVolume
fi

if [[ -z "$newName" ]];
	then
		echo "Current Volume Name Being Used"
	else
		diskutil rename "$pickVolume" "$newName"
		volumeName="$newName"
		pickVolume="/Volumes/$volumeName"
fi

#//Encryption Check - If volume is already encrypted, it will run the function that includes the options only for encrypted volumes
if [[ "$encryptionCheck" == "Yes" ]];
	then
		encryptedVolume
fi

#//Location Check - Verifies the volume selected is an external drive and not an internal drive
if [[ "$deviceLocation" == "External" ]];
	then
		echo "$pickVolume is an external drive"
	else
		echo "$pickVolume is an internal drive and unable to be used"
		exit 0
fi

#//Partition Check - Verifies the 
if [[ "$paritionScheme" == "Apple_Partition_Scheme" ]];
	then
		echo "$partitionScheme is being used. The volume will need to be formatted using GUID in order to apply encryption"
		verifyErase
		eraseVolume
	else
		echo "The partition scheme $partitionScheme is valid and can be encrypted"
		verifyStart
		startEncryption
fi
