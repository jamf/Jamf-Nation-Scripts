#!/bin/sh
#	The purpose of the scripts is to add the hostname of iOS devices to the location field "Room" in the JSS
#


# Define the variables

jssAPIUsername="api"
jssAPIPassword="password"

#Enter in the hostname in the quotes here, replacing https://jss.organization.com:8443 without the trailing slash
jssAddress="https://jss.organization.com:8443"


# Do not edit below this line
# -----------------------------------------------------
# This needs to be done for all devices in the environment, so find out how many devices there are.
#   This is done by getting all devices, then awking out the "size" of it

#       get the xml for all devices
curl -v -k -u $jssAPIUsername:$jssAPIPassword $jssAddress/JSSResource/mobiledevices -X GET > /tmp/allMobileDevices.xml

#       then get the size out of that file
numOfDevices=`cat /tmp/allMobileDevices.xml | xpath //mobile_devices[1]/size 2>/dev/null | sed s/\<size\>//g| sed s/\<\\\/size\>//g`


currentDevice=1

while [ $currentDevice -le $numOfDevices ]
do
#	get the current devices deviceID
	currentDeviceID=`cat /tmp/allMobileDevices.xml | xpath //mobile_devices/mobile_device[$currentDevice]/id 2>/dev/null | sed s/\<id\>//g| sed s/\<\\\/id\>//g`
#	get the current devices hostname
	currentDeviceName=`cat /tmp/allMobileDevices.xml | xpath //mobile_devices/mobile_device[$currentDevice]/device_name 2>/dev/null | sed s/\<device_name\>//g| sed s/\<\\\/device_name\>//g`

# 	Now that we have the name, we'll basically grab it, put it in a custom xml that will get put into the device's location info
	echo "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>
<mobile_device>
	<location>
		<username/>
		<real_name/>
		<email_address/>
		<position/>
		<phone/>
		<department/>
		<building/>
		<room>$currentDeviceName</room>
	</location>
</mobile_device>" > /tmp/deviceFinal.xml 

#	Then, take that /tmp/deviceFinal.xml and put it in the JSS for each device
	curl -k -v -u $jssAPIUsername:$jssAPIPassword $jssAddress/JSSResource/mobiledevices/id/$currentDeviceID -X PUT -T /tmp/deviceFinal.xml
	currentDevice=$((currentDevice+1))

done


#clean up
rm /tmp/allMobileDevices.xml
rm /tmp/deviceFinal.xml
