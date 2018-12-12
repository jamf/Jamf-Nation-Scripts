#!/bin/sh

##########################################
# Disable Smart Card Pairing 				 
# Josh Harvey | Jul 2017				 
# josh[at]macjeezy.com 				 	 
# GitHub - github.com/therealmacjeezy    
# JAMFnation - therealmacjeezy			 
##########################################

############################### Notes ##################################
# This script will find the current logged in user and run the command
# that will disable (turn off) the Smart Card pairing UI. This command
# can only be ran as the current logged in user and will fail if it is 
# ran as SUDO. 
#
########### ISSUES / USAGE #############################################
# If you have any issues or questions please feel free to contact  	    
# using the information in the header of this script.                   
#																		
# Also, Please give me credit and let me know if you are going to use  
# this script. I would love to know how it works out and if you find    
# it helpful.  														    
########################################################################


# Finds the current logged in user and sets it as a variable to be used later in the script
currentUser=`who | grep "console" | cut -d" " -f1`


# Disables the Smart Card UI (Turns off the option for the user to pair their SmartCard in macOS 10.12 by turning off the Pairing UI)
sudo su - "$currentUser" -c "/usr/sbin/sc_auth pairing_ui -s disable"