#!/bin/sh
#
# Creates MASReceipts for specific applications.
# Set $4 as the full app name ie, iphoto.app
#
# Geoffrey O’Brien
# Last Modified - 062214
#
# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 IF NOT, EXIT.

if [ "$4" == "" ]; then
	echo "Error:  No Application Specified."
	exit 1
fi

mkdir /Applications/$4/Contents/_MASReceipt
touch /Applications/$4/Contents/_MASReceipt/receipt