#!/bin/sh


#	This script was written when I noticed a number of machines with no Last-Check-in date in the JSS. Depending 
#	on the size of your enterprise and the number of enrolled computers, this script will take some time to complete.
#	You can pipe the results to a file to save the results. Otherwise the output is to stdout. 

#	Author:		Andrew Thomson
#	Date:		08-10-2016


#JSS_USER=""		#	Un-comment this line and add your login name if different from your os x login account.
#JSS_PASSWORD=""	#	Un-comment this line and add your password to prevent being prompted each time.


if ! JSS_URL=`/usr/bin/defaults read com.jamfsoftware.jss.plist url`; then
	echo "ERROR: Unable to read default url."
	exit $LINENO
fi


if [ -z $JSS_USER ]; then
	JSS_USER=$USER
fi 


if [ -z $JSS_PASSWORD ]; then 
	echo "Please enter JSS password for account: $USER."
	read -s JSS_PASSWORD
fi


#	get computers ids
COMPUTERS=(`/usr/bin/curl -X GET -H"Accept: application/xml" -s -u ${JSS_USER}:${JSS_PASSWORD} ${JSS_URL}JSSResource/computers | /usr/bin/xpath "//id" 2> /dev/null | awk -F'</?id>' '{for(i=2;i<=NF;i++) print $i}'`)


#	enumerate computers for last check-in time
for COMPUTER in ${COMPUTERS[@]}; do
	LAST_CONTACT_TIME=`/usr/bin/curl -X GET -H"Accept: application/xml" -s -u ${JSS_USER}:${JSS_PASSWORD} ${JSS_URL%/}/JSSResource/computers/id/$COMPUTER/subset/general | /usr/bin/xpath "/computer/general/last_contact_time/text()" 2> /dev/null`
	if [ "$LAST_CONTACT_TIME" == "" ]; then 
		/usr/bin/curl -X GET -H"Accept: application/xml" -s -u ${JSS_USER}:${JSS_PASSWORD} ${JSS_URL%/}/JSSResource/computers/id/$COMPUTER/subset/general | /usr/bin/xpath "/computer/general/name/text()" 2> /dev/null
		echo $'\r'
	fi
done


#	audible completion sound
/usr/bin/afplay /System/Library/Sounds/Glass.aiff

