#!/bin/sh

########################################################### HISTORY #############################################################
# 															        #
# Created by Tim Kimpton 15/10/2012												#
# 																#
# This is to be used with Sophos SafeGuard. This will create a SGN POA account and recovery accounts for the logged on user.	#
#																#
# This Script can be used for a logging in policy or if required through other means as root user. 				#
#																#
#################################################################################################################################

# comment in for debug output
# set -x

################# ENVIRONMENT VARIABLES ################################

# NUMBER OF RECOVERY USERS
NUM_RECOVERY_USERS=5

# CURRENT DATE
DATE=`date "+%d-%m-%y_%H.%M"`

# A DUMP FOLDER & FILE (USEFUL FOR AN EXTENSION ATTRIBUTE WITH RECON)
DUMP_FOLDER="/var/tmp/Sophos_SafeGuard"
DUMP_FILE="/var/tmp/recovery_users"

# ABSOLUTE PATH TO BINARIES
SGADMIN="/usr/bin/sgadmin"
WC="/usr/bin/wc"
GREP="/usr/bin/grep"
ECHO="/bin/echo"

# Get the currently logged in user
USER=`ls -l /dev/console | cut -d " " -f4`

# SGADMIN ACCOUNT DETAILS. REPLACE XXX WITH YOUR REQUIRED CREDENTIALS
ADMIN="XXX"
PWDADMIN="XXX"

# DEFAULT POA PASSWORD. REPLACE XXX WITH YOUR REQUIRED CREDENTIALS
DPWD="XXX"

################## DO NOT MODIFY BELOW THIS LINE #########################

# CHECK TO SEE IF POA ACCOUNT EXISTS FOR ${USER}
if 
${SGADMIN} --list-users --authenticate-user "${ADMIN}" --authenticate-password "${PWDADMIN}" | ${GREP} ${USER}
then echo "SGN POA Account exists"
else

# POA ACCOUNT DOES NOT EXIST SO CREATE IT FOR THE LOGGED ON USER
"${SGADMIN}" --add-user --type user --user "${USER}" --password "${DPWD}" --confirm-password "${DPWD}" --authenticate-user "${ADMIN}" --authenticate-password "${PWDADMIN}"
fi

# CHECK THE INPUT  
if [ -z {"USER}" ]; then
        ${ECHO} "Error, no username given. Usage: '`basename $0` username'"
        exit 1
fi

# SET UP REGEX FOR FINDING THE USER
REGEX_USER="^\| user: ${USER}.*\| type: .* \| created: .* \| modified: .* \|$"

# SETUP REGEX FOR FINDING THE RECOVERY ACCOUNTS
REGEX_RECOVERY_USER="^\| user: .* \| type: recovery \| created: .* \| modified: .* \| recovers: ${USER}.*\|$"

# CHECK TO SEE IF ${USER} EXISTS
${SGADMIN} --list-users --authenticate-user "${ADMIN}" --authenticate-password "${PWDADMIN}" \
	| ${GREP} -E "${REGEX_USER}" > /dev/null 2>&1
if [ $? -ne 0 ]; then
	${ECHO} "Error, user '${USER}' does not exist."
	exit 1
fi

# COUNT THE RECOVERY ACCOUNTS FOR ${USER}
ACTUAL_RECOVERY_USERS=`${SGADMIN} --list-users --authenticate-user "${ADMIN}" --authenticate-password "${PWDADMIN}" \
	| ${GREP} -E "${REGEX_RECOVERY_USER}" | ${WC} -l`

# HOW MANY ADDITIONAL RECOVERY ACCOUNTS?
declare -i DIFF="${NUM_RECOVERY_USERS} - ${ACTUAL_RECOVERY_USERS}"

if [ ${DIFF} -gt 0 ]; then

# IF ADDITIONAL RECOVERY ACCOUNTS ARE REQUIRED CREATE THEM AND WRITE TO A DUMP FILE.
hostname>"${DUMP_FILE}"
${ECHO} "Creating recovery users for user '${USER}':" >> "${DUMP_FILE}" 2>&1
	${SGADMIN} --add-recovery-users --authenticate-user "${ADMIN}" --authenticate-password "${PWDADMIN}" \
		--user-to-recover "${USER}" --count "${DIFF}" >> "${DUMP_FILE}" 2>&1 

# MAKE SURE THE DUMP FOLDER EXISTS
mkdir "${DUMP_FOLDER}"

# PAUSING 5 SECONDS
sleep 5

# CHANGING PERMISSIONS OF THE DUMP FOLDER
chmod -R 777 "${DUMP_FOLDER}"

# MOVING THE FILE
mv "${DUMP_FILE}" /"${DUMP_FOLDER}"/recovery_users_"${DATE}".txt	

# CHANGING PERMISSIONS OF ${DUMP_FOLDER}
chown -R root:admin "${DUMP_FOLDER}"
chmod -R 770 "${DUMP_FOLDER}"

# PAUSING 5 SECONDS
sleep 5

# CHECK TO SEE IF THERE ARE ANY ERRORS AND ECHO RELEVANT INFORMATION
if [ $? -ne 0 ]; then
		${ECHO} "Error, '${SGADMIN}' exited with error code '$?'."
		exit 1
	fi
	${ECHO} "Successfully created ${DIFF} recovery users for user '${USER}'. Additional information can be found in '${DUMP_FOLDER}'"
fi

# Enable Single Sign On
${SGADMIN} --enable-sso --authenticate-user "${ADMIN}" --authenticate-password "${PWDADMIN}"

exit 0

