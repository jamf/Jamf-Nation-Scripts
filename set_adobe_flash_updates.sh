#!/bin/sh

# This script configures Adobe Flash auto + silent update settings

# Set auto update values of the Adobe mms.cfg file
mms='AutoUpdateDisable=0
SilentAutoUpdateEnable=1'

# Check + delete if mms.cfg exists
if [ -e /Library/Application\ Support/Macromedia/mms.cfg ]; then
	echo "mms.cfg file exists. Deleting + recreating."
	rm /Library/Application\ Support/Macromedia/mms.cfg
	# create new mms.cfg file with correct update settings
	echo "$mms" >> /Library/Application\ Support/Macromedia/mms.cfg
	chmod 755 /Library/Application\ Support/Macromedia/mms.cfg
else
	echo "No mms.cfg file. Creating now."
	# create new mms.cfg file with correct update settings
	mkdir /Library/Application\ Support/Macromedia
	echo "$mms" >> /Library/Application\ Support/Macromedia/mms.cfg
	chmod 755 /Library/Application\ Support/Macromedia/*
fi

exit 0