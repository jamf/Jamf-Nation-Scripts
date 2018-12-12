#!/bin/bash
########################################################
# Remove and reset Symantec EndPoint Protection Tasks
# Cobbled together from others hard work by Christopher Miller 
# for ITSD-ISS of JHU-APL, Dated 20140107
########################################################
# This will purge any scheduled jobs and generate
# a new random 24-hour time to perform updates
# thus keeping traffic on the network and demand on 
# the server to scattered schedules between 6AM & 9PM
# the timeframe is adjustable and noted below.  
# NOTE: This uses 24-hour time, so limit high hour constraint to 23
# NOTE: Again, using 24-hour time, so limit high minute constraint to 59
########################################################

# A Listing of commands is available by typing 'symsched' into Terminal
#
# Sample Format is as follows:
# Module         Name                     On  UI  Freq     Day   Time   Args
# -------------- ------------------------ --- --- -------- ----- ------ ----
# LiveUpdate     Update All Daily         1   0   Daily          13:00  "All Products" -quiet

# An example setup is below
# Schedule a Monthly Scan Silently of the System on the 28th @ 11PM, 
# Ensure 20 mins idle time, the target is the '/' Boot Volume
#/usr/bin/symsched VirusScan "Monthly Scan" 1 0 -monthly 28 23:00 -niceness -20 /

# TAKE NOTE: Schedules are saved 'per user' 
# If you perform these actions within root or another management account
# the schedules will NOT appear from other accounts.  

###########################################################
# Actionable tasks for the script are below
# This sets a new update schedule, it does NOT set a 
# schedule for scanning, refer to line 26 example if desired
###########################################################

# Remove any currently scheduled Tasks
/usr/bin/symsched -d all

# Set a variable "NewHour" to a randomized number with constraints to 06:00 & 20:00 hours 
# You may adjust hours below to suit your needs
NewHour=$(jot -r 1 6 20)

# Set a variable "NewMin" to a randomized number with constraints to :00 and :59 minutes
# Note: It is NOT recommend to adjust the minutes constraints 
NewMin=$(jot -r 1 0 59)

# Use the variables to make a new randomized time
# Schedule a Task for Updating All SEP Products daily @ a new random time Silently
/usr/bin/symsched LiveUpdate "Update All Daily" 1 0 -daily $NewHour:$NewMin "All Products" -quiet

# Display the currently scheduled Tasks
/usr/bin/symsched -l

exit 0