#!/bin/bash


function stop () {

sudo launchctl unload /Library/LaunchDaemons/com.opendns.osx.RoamingClientConfigUpdater.plist

#variable for storing the current users name
currentuser=`stat -f "%Su" /dev/console`

#substituting as user stored in variable to modify plist
su "$currentuser" -c "launchctl remove com.opendns.osx.RoamingClientMenubar"


#sudo killall OpenDNSDiagnostic

}



function start () {

sudo launchctl load /Library/LaunchDaemons/com.opendns.osx.RoamingClientConfigUpdater.plist

#variable for storing the current users name
currentuser=`stat -f "%Su" /dev/console`

#substituting as user stored in variable to modify plist
su "$currentuser" -c "launchctl load /Library/LaunchAgents/com.opendns.osx.RoamingClientMenubar.plist"
}





ps auwwx | egrep "dnscrypt|RoamingClientMenubar|dns-updater" | grep -vq egrep;
if [[ 0 == $? ]]; then
    echo "Umbrella is running."
    stop;
 
else
    echo "Umbrella is stopped"
    start;

fi
