#!/bin/sh
# jss_api_id_staticgroup.sh
#
# Created by Andrew Seago on 07/31/13.
# 
#	This script takes a list of jssIDs and updates a static group with those systems. 
# 	It is important to already have created a blank static group or a static group that you are going to completly overwrite
#	This should not be used on or work on smart groups
#	Use this at your own risk. It works for me but each enviroment is different. 
#	If you get alot of errors your $JSS_ID_PATH file may need to resaved with textwrangler or textmate. 
#	I found issues when Excel or Word saved the file last
#
# 
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Variables
#################################################################################################### 

# Variables used by this script
JSS_ID_PATH="" # Text file with one JSS ID per Line
JSS_API_INFO_DIR="/tmp/jss_api_tmp" # Directory where working files for each JSS ID will be stored
JSS_XML_INPUT="/tmp/JSS_XML_INPUT.xml" # XML Output to be uploaed to the JSS Computer Groups API
STATIC_GROUP_ID="" # Static Group ID: This can be found in the URL when you click edit on a Static Group
STATIC_GROUP_NAME="" # This is the name of the Static Group you want to overwrite

# Variables used by Casper
USERNAME="" #Username of user with API Computer read GET and Computer Group PUT access
PASSWORD="" #Password of user with API Computer read GET and Computer Group PUT access
JSS_URL='https://jss.jamf.com:8443' # JSS URL of the server you want to run API calls against

## Functions
#################################################################################################### 
# This creates an xml dump from the JSS API in the $JSS_API_INFO_DIR
function CheckAPI () {
	for system in `cat $JSS_ID_PATH | awk '{print$1}'`; do
		curl -v -u "$USERNAME":"$PASSWORD" $JSS_URL/JSSResource/computers/id/$system/subset/General -X GET  > "$JSS_API_INFO_DIR/$system.xml"
	done
	CreateXML
}

# This creates the first part of the XML header 
function CreateXML () {
	number_of_systems=`ls $JSS_API_INFO_DIR | wc | awk '{print$1}'`
	echo '<?xml version="1.0" encoding="UTF-8" standalone="no"?><computer_group><id>' > "$JSS_XML_INPUT"
	echo "$STATIC_GROUP_ID" >> "$JSS_XML_INPUT"
	echo '</id><name>' >> "$JSS_XML_INPUT"
	echo "$STATIC_GROUP_NAME" >> "$JSS_XML_INPUT"
	echo '</name><is_smart>false</is_smart><criteria/><computers><size>' >> "$JSS_XML_INPUT" 
	echo "$number_of_systems" >> "$JSS_XML_INPUT" 
	echo '</size>' >> "$JSS_XML_INPUT" 
	ParseXML
}

# This goes through the xml dumps and writes out the jssid, mac_address and name for each system into the $JSS_XML_INPUT that will be uploaded to the jss
function ParseXML () {
	for system in `cat $JSS_ID_PATH | awk '{print$1}'`; do
		id=`Xpath "$JSS_API_INFO_DIR/$system.xml" //id`
		mac_address=`Xpath "$JSS_API_INFO_DIR/$system.xml" //mac_address`
		name=`Xpath "$JSS_API_INFO_DIR/$system.xml" //name`
		echo '<computer>' >> "$JSS_XML_INPUT"
		echo "$id" >> "$JSS_XML_INPUT"
		#echo '</id><name>' >> "$JSS_XML_INPUT"
		echo "$name" >> "$JSS_XML_INPUT"
		#echo '</name><mac_address>' >> "$JSS_XML_INPUT"
		echo "$mac_address" >> "$JSS_XML_INPUT"
		echo '<serial_number/></computer>' >> "$JSS_XML_INPUT"
	done
	FinalizeXML
}

# This writes the final closing xml to the $JSS_XML_INPUT file and removes all carriage returns so that it is all on one line
function FinalizeXML () {
	echo '</computers></computer_group>' >> "$JSS_XML_INPUT"
	perl -pi -e 'tr/[\012\015]//d' "$JSS_XML_INPUT"
	UpdateStaticGroup
}

# This uploads the $JSS_XML_INPUT file to the JSS
function UpdateStaticGroup () {
	curl -k -v -u "$USERNAME":"$PASSWORD" $JSS_URL/JSSResource/computergroups/id/514 -T "$JSS_XML_INPUT" -X PUT
	echo "$?"
	echo "Done"
}

## Script
#################################################################################################### 
# Script Action 1

CheckAPI
