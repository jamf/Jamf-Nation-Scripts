#!/bin/sh

##########################################
# AD Join Script - Centrify 				 
# Josh Harvey | Jul 2017				 
# josh[at]macjeezy.com 				 	 
# GitHub - github.com/therealmacjeezy    
# JAMFnation - therealmacjeezy			 
##########################################

############################### Notes ##################################
# This script will bind the computer to Active Directory using the
# Centrify client.
# 
# The reason for this script was due to the built in Directory Binding
# Configurations that the JSS uses for Centrify were hit or miss on 
# actually binding the computer to AD. This script will take the input
# you enter in the Parameters and use them to bind the computer using
# adjoin.
#
###### Parameters ######################################################
# 4 - Domain Admin Username
# 5 - Domain Admin Password
# 6 - Encode Password (See Below - Leave blank for plain text)
# 7 - Centrify Zone (Leave blank for Auto Zone)
# 8 - Domain Being Joined
#
# If you don't want to have your actual password to be used in plain
# text, you can enter "Yes" for Parameter 6. When encoding your password
# you will have to do the following steps:
# 	1. In terminal enter 'echo "passwordhere" | base64'
# 	2. Copy the output and paste it into Parameter 5
#	NOTE: If your password has special characters in it, be sure to 
#	comment them out when getting the base64 output 
#	(Example:'echo "p\@\$\$w0rd\!23" | base64')
#
########### ISSUES / USAGE #############################################
# If you have any issues or questions please feel free to contact  	    
# using the information in the header of this script.                   
#																		
# Also, Please give me credit and let me know if you are going to use  
# this script. I would love to know how it works out and if you find    
# it helpful.  														    
########################################################################

decodePW() {
	# Decode password
	adPass=`echo "$password" | base64 -D`
}

# Pull Computer Name
computerName=`scutil --get ComputerName`

# Parameter Check
# Domain Username Check
if [[ -z "$4" ]];
	then
		echo "Error: Domain Admin Username Missing"
		errorFound=Yes
else
		username="$4"
fi

# Domain Password Check
if [[ -z "$5" ]];
	then
		echo "Error: Domain Admin Password Missing"
		errorFound=Yes
elif [[ "$6" == "Yes" ]]
	then
		password=`echo "$5" | base64 -D`
else
		password="$5"
fi

# Encode Password Check
#if [[ -z "$6" ]];
#	then
#		echo "Skipping Password Decode"
#else
#		decodePW
#		password="$adPass"
#fi

# Centrify Zone Check
if [[ -z "$7" ]];
	then
		echo "Using the Auto Zone option"
		useAZ=Yes
else
		zone="$7"
fi

# Domain Check
if [[ -z "$8" ]];
	then
		echo "Error: Domain Missing"
		errorFound=Yes
else
		domain="$8"
fi


#//This function joins the computer to the domain using the variables previously gathered
domainJoin() {
	#sudo /usr/local/sbin/adjoin -u "\"$username\"" -p "\"$password\"" -n "\"$computerName\"" -z "\"$zone\"" -f "\"$domain\""
    # Uncomment line below and command line above for testing
    echo "sudo /usr/local/sbin/adjoin -u "\"$username\"" -p "\"$password\"" -n "\"$computerName\"" -z "\"$zone\"" -f "\"$domain\"""
}

domainJoinAZ() {
	#sudo /usr/local/sbin/adjoin -u "\"$username\"" -p "\"$password\"" -n "\"$computerName\"" -w -f "\"$domain\""
	# Uncomment line below and command line above for testing
	echo "sudo /usr/local/sbin/adjoin -u "\"$username\"" -p "\"$password\"" -n "\"$computerName\"" -w -f "\"$domain\"""
}

# If an error occurs while getting the parameters, it will exit with an error
if [[ "$errorFound" == "Yes" ]];
	then
		exit 1
fi

# Catches the option for Auto Zone join
if [[ "$useAZ" == "Yes" ]];
	then
		domainJoinAZ
else
		domainJoin
fi