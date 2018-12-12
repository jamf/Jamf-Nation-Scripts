#!/bin/sh

#	This script was written to automate the re-partitioning of drives for Macs using
#	a logical volume group and a logical drive. Fusion drives are supported as well 
#	as single-disk systems. This script assumes it is running from a NetBoot environment
#	where drives can be unmounted, partitioned and reformatted freely. Use at your own risk.

#	Author:		Andrew Thomson
#	Date:		02-04-2015



function  countDisks() {
	
	#	reset array
	unset ARRAY_DISKS

	#	enumerate all installed disks
	ARRAY_DISKS=(`/usr/sbin/diskutil list | awk -F: '/dev/ {print $NF}'`)
	echo "The count of installed disks is: ${#ARRAY_DISKS[@]}."


	#	remove any external disks from the array
	for INDEX in $(seq 0 $((${#ARRAY_DISKS[@]}-1))); do
		if /usr/sbin/diskutil info ${ARRAY_DISKS[$INDEX]} | grep Internal: | grep No > /dev/null; then
			unset ARRAY_DISKS[$INDEX]
		fi
	done
	echo "The count of internal disks is: ${#ARRAY_DISKS[@]}."
	
}


function countLogicalVolumes() {
	
	#	reset array
	unset ARRAY_LOGICAL_VOLUMES
	
	#	refresh disk count
	countDisks
	
	#	enumerate internal disks to find logical volumes
	for INDEX in $(seq 0 $((${#ARRAY_DISKS[@]}-1))); do
		if /usr/sbin/diskutil list ${ARRAY_DISKS[$INDEX]} | grep "Logical Volume" > /dev/null; then
			ARRAY_LOGICAL_VOLUMES+=(${ARRAY_DISKS[$INDEX]})
		fi
	done
	echo "The count of logical volumes is: ${#ARRAY_LOGICAL_VOLUMES[@]}."
	echo "----------"

}

#	initialize disk counts
countLogicalVolumes


#	only delete and recreate primary partion if no logical volumes found.
if [ ${#ARRAY_LOGICAL_VOLUMES[@]} -eq 0 ]; then
	if /usr/sbin/diskutil partitionDisk disk0 GPT JHFS+ "Macintosh HD" 100% > /dev/null; then
		echo "Successfully deleted and recreated primary parititon."
		exit 0
	else
		"ERROR: Unable to delete and recreate primary partition."
		exit $LINENO
	fi
fi
		
	
#	delete any found logical volumes
if [ ${#ARRAY_LOGICAL_VOLUMES[@]} -ne 0 ]; then
	for INDEX in $(seq 0 $((${#ARRAY_LOGICAL_VOLUMES[@]}-1))); do
		if /usr/sbin/diskutil cs deleteVolume ${ARRAY_LOGICAL_VOLUMES[$INDEX]} > /dev/null; then
			echo "Successfully deleted logical volume on: ${ARRAY_LOGICAL_VOLUMES[$INDEX]}."
		else
			echo "ERROR: Unable to delete logical volume on ${ARRAY_LOGICAL_VOLUMES[$INDEX]}."
			exit $LINENO
		fi
	done
	echo "----------"
	countDisks
fi


#	delete any internal disks
if [ ${#ARRAY_DISKS[@]} -ne 0 ]; then
	for INDEX in $(seq 0 $((${#ARRAY_DISKS[@]}-1))); do
		if /usr/sbin/diskutil partitionDisk ${ARRAY_DISKS[$INDEX]} GPT "Free Space" "Untitled $INDEX" 100%  > /dev/null; then
			echo "Successfully deleted disk: ${ARRAY_DISKS[$INDEX]}."
		else
			echo "ERROR: Unable to delete disk: ${ARRAY_DISKS[$INDEX]}."
			exit $LINENO
		fi
	done
	echo "----------"
fi


#	create logical volume group
if [ ${#ARRAY_DISKS[@]} -ne 0 ]; then
	if /usr/sbin/diskutil cs create "Macintosh HD" ${ARRAY_DISKS[@]} > /dev/null; then
		echo "Successfully created logical volume group."
		
		#	get UUID of newly created logical volume group
		UUID=`/usr/sbin/diskutil cs list | grep "Logical Volume Group" | awk '{print $5}'`
		if [ -n $UUID ]; then 
			#	create logical volume
			if /usr/sbin/diskutil cs createVolume $UUID JHFS+ "Macintosh HD" 100% > /dev/null; then
				echo "Successfully created logical volume."
			else
				echo "ERROR: Unable to create logical volume."
				exit $LINENO
			fi
		else
			echo "ERROR: Unable find logical volume group UUID."
			exit $LINENO
		fi
	else
		echo "ERROR: Unable to create logical volume group."
		exit $LINENO
	fi
fi