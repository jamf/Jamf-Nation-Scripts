#!/usr/bin/python
# -*- coding: utf-8 -*-
####################################################################################################
#
# Copyright (c) 2012, JAMF Software, LLC.  All rights reserved.
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
#       This program is distributed "as is" by JAMF Software, LLC.
#
####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#    updateDeviceInventory.py -- Update Mobile Device Inventory
#
# SYNOPSIS
#    /usr/bin/python updateDeviceInventory.py
#    
# DESCRIPTION
#    This script was designed to update all mobile device inventory in a JSS.
#
#    For the script to function properly, users must be running the JSS version 7.31 or later and
#    the account provided must have API privileges to "READ" and "UPDATE" mobile devices in the JSS.
#
####################################################################################################
#
# HISTORY
#
#    Version: 1.1
#
#    - Created by Nick Amundsen on June 23, 2011
#    - Updated by Nick Amundsen on November 10, 2015
#           - Updated to support TLS instead of SSL
#           - Fixed JSON parsing issue
#           - Various updates to modernize parameters, etc
#
#####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
#####################################################################################################
#
# HARDCODED VALUES SET HERE
#
jss_url = "" #Example: https://jss.company.com/
jss_username = ""
jss_password = ""

##DONT EDIT BELOW THIS LINE
import sys 
import json
import httplib
import base64
import urllib2
import socket
import ssl

##Computer Object Definition
class Device:
    id = -1

##Check variable
def verifyVariable(name, value):
    if value == "":
        print "Error: Please specify a value for variable \"" + name + "\""
        sys.exit(1)

## the main function.
def main():
    verifyVariable("jss_url",jss_url)
    verifyVariable("jss_username",jss_username)
    verifyVariable("jss_password",jss_password)
    devices=grabDeviceIDs()
    updateDeviceInventory(devices)

##Grab and parse the mobile devices and return them in an array.
def grabDeviceIDs():
    devices=[];
    ## parse the list
    for deviceListJSON in (getDeviceListFromJSS()["mobile_devices"]):
        d = Device()
        d.id = deviceListJSON.get("id")
        devices.append(d)  
    print "Found " + str(len(devices)) + " devices."
    return devices


##Download a list of all mobile devices from the JSS API
def getDeviceListFromJSS():
    print "Getting device list from the JSS..."
    try:
        opener = urllib2.build_opener(TLS1Handler())
        request = urllib2.Request(jss_url + "/JSSResource/mobiledevices")
        request.add_header("Authorization", Utils.getAuthHeader(jss_username,jss_password))
        request.add_header("Accept", "application/json")
        request.get_method = lambda: 'GET'
        response = opener.open(request)
        data = response.read()
        print data
        return json.loads(data)
    except httplib.HTTPException as inst:
        print "\tException: %s" % inst
    except ValueError as inst:
        print "\tException obtaining Device List: %s" % inst
    except urllib2.HTTPError as inst:
        print "\tException obtaining Device List: %s" % inst
    except:
        print "\tUnexpected error obtaining Device List:", sys.exc_info()


##Submit the command to update a device's inventory to the JSS
def updateDeviceInventory(devices):
    print "Updating Devices Inventory..."
    ##Parse through each device and submit the command to update inventory
    for index, device in enumerate(devices):
        percent = "%.2f" % (float(index) / float(len(devices)) * 100)
        print str(percent) + "% Complete -"
        submitDataToJSS(device)
    print "100.00% Complete"

##Update data for a single device
def submitDataToJSS(Device):
    print "\tSubmitting command to update device id " +  str(Device.id) + "..."
    try:
        url = jss_url + "/JSSResource/mobiledevices/id/" + str(Device.id)
        #Write out the XML string with new data to be submitted
        newDataString = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?><mobile_device><command>UpdateInventory</command></mobile_device>"
        #print "Data Sent: " + newDataString
        opener = urllib2.build_opener(TLS1Handler())
        request = urllib2.Request(url,newDataString)
        request.add_header("Authorization", Utils.getAuthHeader(jss_username,jss_password))
        request.add_header('Content-Type', 'application/xml')
        request.get_method = lambda: 'PUT'
        opener.open(request)
    except httplib.HTTPException as inst:
        print "\tException: %s" % inst
    except ValueError as inst:
        print "\tException submitting PUT XML: %s" % inst
    except urllib2.HTTPError as inst:
        print "\tException submitting PUT XML: %s" % inst
    except:
        print "\tUnknown error submitting PUT XML."



class Utils:
    @staticmethod
    def getAuthHeader(u,p):
        # Compute base64 representation of the authentication token.
        token = base64.b64encode('%s:%s' % (u,p))
        return "Basic %s" % token


#Force TLS since the JSS now requires TLS+ due to the POODLE vulnerability
class TLS1Connection(httplib.HTTPSConnection):
    def __init__(self, host, **kwargs):
        httplib.HTTPSConnection.__init__(self, host, **kwargs)
    
    def connect(self):
        sock = socket.create_connection((self.host, self.port), self.timeout, self.source_address)
        if getattr(self, '_tunnel_host', None):
            self.sock = sock
            self._tunnel()
                                            
        self.sock = ssl.wrap_socket(sock, self.key_file, self.cert_file, ssl_version=ssl.PROTOCOL_TLSv1)

class TLS1Handler(urllib2.HTTPSHandler):
    def __init__(self):
        urllib2.HTTPSHandler.__init__(self)
    
    def https_open(self, req):
        return self.do_open(TLS1Connection, req)

## Code starts executing here. Just call main.
main()