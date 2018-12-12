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
#	importCACert.sh -- Import CA Certficate to the System Keychain.
#
# SYNOPSIS
#	sudo importCACert.sh
#	sudo importCACert.sh <mountPoint> <computerName> <currentUsername> <caCertLocation> 
#
#	If no hardcoded values are specified for the above parameters, and there is a value 
#	passed for the parameters by the Casper Suite, the values passed will apply.
#
#	If there are hardcoded values specified for the above parameters, those values will 
#	supersede any value passed by the Casper Suite.
#
#	The value specified for "caCertLocation" should be a path to the certificate, formatted in the
#	".pem" format on a machine.  It is assumed that this script is being run after deploying the
#	CA certificate via a package to a location such as "/Library/Application Support/JAMF" on the 
#	machine.
#
#
# DESCRIPTION
#	This script will import a ".pem" or ".cer" certificate from a given location on the machine to the system
#	keychain.  This script assumes the following workflow is taking place:
#
#	1.) Create a package of the ".pem" or ".cer" formatted certificate being deployed to a location such as:
#	
#			"/Library/Application Support/JAMF"
#
#	2.) Upload the package to Casper Admin
#
#	3.) Edit the "caCertLocation" variable located within this script to reflect the location of
#		the CA cert as it was packaged.  
#		
#		For example, if we have a certficate named "CompanyCA.cer"
#		that was packaged to be installed to "/Library/Application Support/JAMF", we would set the
#		"caCertLocation" variable to "/Library/Application Support/JAMF/CompanyCA.cer"
#	
#	4.) Upload the script to Casper Admin and ensure that a script priority of "After" is selected
#
#	5.) Create a policy that will install the package containing the CA cert and run this script
#		after installing the package.
#	
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Nick Amundsen on October 13, 2010
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

# HARDCODED VALUES ARE SET HERE
caCertLocation=""	#Example: "/Library/Application Support/JAMF/CompanyCA.pem"

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "caCertLocation"
if [ "$4" != "" ] && [ "$caCertLocation" == "" ];then
    caCertLocation=$4
fi

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################
OS=`/usr/bin/defaults read /System/Library/CoreServices/SystemVersion ProductVersion | awk '{print substr($1,1,4)}'`

if [ "$caCertLocation" == "" ] || [ ! -f "$caCertLocation" ]; then
	echo "Error:  No value was specified for the caCertLocation variable or the file does not exist.  Please specify a value for the variable or ensure that you are running this script after installing the certificate."
	exit 1
fi

if [[ "$OS" < "10.5" ]]; then
	echo "Importing CA Cert..."
	/usr/bin/certtool i "$caCertLocation" v k=/System/Library/Keychains/X509Anchors
else
	echo "Importing CA Cert..."
	/usr/bin/security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "$caCertLocation"
fi