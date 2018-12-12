#!/bin/sh
##########################################################################################
#### Created by Andrew Zbikowski <andyzib@gmail.com> #####################################
## Intended for use before performing an upgrade of VMware Fusion. This script will find 
## the vmrun command included with VMware Fusion 2 and above and use it to suspend any   
## virtual machines currently running. 
########################################################################################## 

# Glob based on new line. 
IFS='
'

# Find vmrun, not sure where it is on v4, but one of these should catch it. 
if [ -e "/Applications/VMware Fusion.app/Contents/Library/vmrun" ]; then
	# Fusion 5, 6.
	VMRUN="/Applications/VMware Fusion.app/Contents/Library/vmrun"
elif [ -e "/Library/Application Support/VMware Fusion/vmrun" ]; then
	# Fusion 3, 2. 
	VMRUN="/Library/Application Support/VMware Fusion/vmrun"
else
	# Fusion 1... :-(
	exit 1
fi

VMLIST=`"$VMRUN" list`

# If someone has managed to get more than 9 VMs running there are other problems... 
# This just needs to be a non-zero for the script to take action, so this is fine. 
NUMVMS=${VMLIST:19:1}
if [ $NUMVMS = 0 ]; then
	#echo "No VMs running, nothing to do."
	exit 0
fi

# Suspend every running VM. 
for i in ${VMLIST[*]}; do
	if [ ! `echo $i | cut -c 1-5` = "Total" ] ; then
		#echo $i
		"$VMRUN" suspend "$i"
	fi
done

# If there are still VMs running, use the hard option. 
VMLIST=`"$VMRUN" list`
NUMVMS=${VMLIST:19:2}

if [ $NUMVMS = 0 ]; then
	#echo "No VMs running, nothing to do."
	exit 0
fi

for i in ${VMLIST[*]}; do
	if [ ! `echo $i | cut -c 1-5` = "Total" ] ; then
		#echo $i
		"$VMRUN" suspend "$i" hard
	fi
done

# If there are still VMs running at this point, we did our best. 

exit 0