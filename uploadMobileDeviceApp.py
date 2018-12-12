#!/usr/bin/python
# -*- coding: utf-8 -*-
####################################################################################################
#
# Copyright (c) 2011, JAMF Software, LLC
# All rights reserved.
#
#
# OWNERSHIP OF INTELLECTUAL PROPERTY:
#    
#    JAMF Software, LLC (JAMF) will retain ownership of all proprietary rights to the source code and 
#    object code of the Software. Upon full payment of the fees set forth in this agreement, JAMF 
#    will grant to Customer a non-exclusive, non-transferable license to install and use the Software
#    within its own organization.
#    
#    The license shall authorize Customer to:
#        a)    Install the Software on computer systems owned, leased, or otherwise controlled by 
#        Customer
#        b)    Utilize the Software for its internal data processing purposes 
#        c)    Copy the Software only as necessary to exercise the rights granted in this Agreement
#    
#
# WARRANTY AND DISCLAIMER:
# 
#    JAMF will offer the following express warranties through the Agreement:
#
#    Warranty of Software Performance
#    JAMF warrants that for a period of 5 (five) business days following acceptance (receipt) of 
#    the Software by Customer, the Software will be free from defects in workmanship and materials, 
#    and will conform as closely as possible to the specifications provided in the Development Plan 
#    contained within this Agreement. If material reproducible programming errors are discovered 
#    during the warranty period, JAMF shall promptly remedy them at no additional expense to Customer.
#    This warranty to Customer shall be null and void if Customer is in default under this Agreement 
#    or if the nonconformance is due to:
#
#        a)    Hardware failures due to defects, power problems, environmental problems, or any cause 
#        other than the Software itself
#        b) ModificationoralterationoftheSoftware,OperatingSystems,orHardwaretargetsspecified in the
#        Development Plan contained within this Agreement
#        c)    Misuse, errors, or negligence by Customer, its employees, or agents in operating the 
#        Software
#
#    JAMF shall not be obligated to cure any defect unless Customer notifies JAMF of the existence 
#    and nature of such defect promptly upon discovery within the warranty period.
#
#    Warranty of Title:
#    JAMF owns and reserves the right to license or convey title to the Software and documentation 
#    that arises out of the nature of this Agreement.
#
#    Warranty Against Disablement
#    JAMF expressly warrants that no portion of the Software contains or will contain any protection 
#    feature designed to prevent its use. This includes, without limitation, any computer virus, worm,
#    software lock, drop dead device, Trojan-horse routine, trap door, time bomb or any other codes 
#    or instructions that may be used to access, delete, damage, or disable Customer Software or 
#    computer system. JAMF further warrants that it will not impair the operation of the Software in 
#    any other way than by order of a court of law.
#
#    Warranty of Compatibility
#    JAMF warrants that the Software shall be compatible with Customer specific hardware and software 
#    titles and versions as set forth in the Development Plan of this Agreement. No warranty, express,
#    or implied will be made on versions of hardware or software not mentioned in the Development Plan
#    of this agreement.
#
#    The warranties set forth in this Agreement are the only warranties granted by JAMF. JAMF disclaims 
#    all other warranties, express or implied, including, but not limited to, any implied warranties 
#    of merchantability or fitness for a particular purpose.
#
#
#
# LIMITATION OF LIABILITY:
#
#    In no event shall JAMF be liable to Customer for lost profits of Customer, or special or
#    consequential damages, even if JAMF has been advised of the possibility of such damages.
#
#    JAMF Software's total liability under this Agreement for damages, costs and expenses, regardless of cause
#    shall not exceed the total amount of fees paid to JAMF by Customer under this Agreement.
#
#    JAMF shall not be liable for any claim or demand made against Customer by any third party.
#
#    Customer shall indemnify JAMF against all claims, liabilities and costs, including reasonable 
#    attorney fees, of defending any third party claim or suit arising out of the use of the Software 
#    provided under this Agreement.
#
####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#    uploadMobileDeviceApp.py -- Upload Mobile Device App
#
# SYNOPSIS
#    sudo python uploadMobileDeviceApp.py
#    
# DESCRIPTION
#    This script was designed to upload internally developed mobile device applications to the JSS
#
#    For the script to function properly, users must be running the JSS version 8.0 or later and
#    the account provided must have API privileges to "READ", "CREATE", and "UPDATE" 
#    mobiledeviceapplications in the JSS, as well as the "READ", "CREATE", and "UPDATE" privileges 
#    for mobiledeviceprovisioningprofiles in the JSS.
#
#    To run, fill in the variables specified in the section titled "HARDCODED VALUES SET HERE", then
#    execute the script.
#
####################################################################################################
#
# HISTORY
#
#    Version: 1.2
#
#    - Created by Nick Amundsen on November 1, 2010
#	 - Updated by Blia Xiong on October 18, 2011
#		- Added ability to pass parameters
#		- Added functionality to deploy apps automatically
#		- Improved uploads of large apps
#	 - Updated by Nick Amundsen on November 14, 2011
#		- Fixed an issue with the API not accepting uppercase boolean values ("True" vs "true")
#
#####################################################################################################
#
# DEFINE VARIABLES 
#
#####################################################################################################
logFile = "/private/var/log/uploadMobileDeviceApp.log" #Location to save the log file
interactiveLogMode = True 	#Set to true to display output to log and stdout, false to display output to log only

#### Global JSS Info
jss_host = ""	 					#JSS Address
jss_port = "8443"						#JSS Port
jss_path = ""						#JSS Path - leave blank for standard JSS Installations
jss_username = ""					#JSS Username
jss_password = ""					#JSS Password

#### Global mobile app Info
name = ""							#Display Name of the App to upload Ex: "Chart Visualizer"
description = "" 					#Optional description of the application Ex: "This is an charting application"
bundle_id = "" 	 					#App bundle id Ex: "com.jamfsoftware.inhouse.Chart-Visualizer"
version = ""						#App version Ex: "1.0"
path_to_ipa = ""					#Path to the IPA file to upload Ex: "/Users/admin/Desktop/Chart.IPA"
path_to_icon = ""	 				#Path to the icon to upload Ex:"/Users/admin/Desktop/Chart.png"
internal_app = True					#Boolean value - In-house app or purchased from App Store
auto_deploy_app = False				#Boolean value - Set app as auto deploy
deploy_as_managed_app = True		#Boolean value - App will be set to managed when deployed
remove_app_with_MDMProf = False		#Boolean value - App will be removed when MDM profile is deleted
prevent_app_databackup = False		#Boolean value - Prevents app from backing up data to mobile device
free_app = True						#Boolean value - Detemines whether free app (App Store or In-house) or purchased

#### Global Prov Profile Info
prov_profile_name = ""			#Display Name of the .mobileprovision profile to upload Ex: "Company Name"
prov_profile_path = "" 			#Path to the .mobileprovision file to upload Ex: "/Users/admin/Desktop/Company_Name.mobileprovision"


##################################    DONT EDIT BELOW THIS LINE    ##################################

#### Imports
from sys import argv
import httplib
import urllib2
from xml.dom import minidom
import re
import os
import sys
import logging
import signal
import commands
import base64
from subprocess import Popen, PIPE

# Define a profile class for use later
class profile:
    id = None
    name = None
    uuid = None

#### Global Arrys of flag names
hostParams = ["-jssHost","-jssPort","-jssPath","-jssUser","-jssPass"]
appParams = ['-appName', '-appDesc', '-appBundleID', '-appVersion', '-pathToIPA', '-pathToIcon' ]
appOptions = ["-internalApp", "-autoDeployApp", "-deployAsManagedApp", "-removeAppWithMDMProf", "-preventAppDataBackup", "-freeApp"]
profileParams = ['-provisionProfName', '-pathToProvisionProfile']

#### This will store all the values and flags passed into this script
values = None
profile = profile()
app_meta_data = None				#App meta data xml file

# Initialize...
def initAll():
	global values
	global hasAppData
	global hasProvProfData
	
	hasAppData = False
	hasProvProfData = False
		
	numArgs = None
	# This will determine if script will use param arguments or hard coded values
	if len(argv) > 1:
		argv.pop(0) 
		assignParamValues() # Store arguments into dictionary
		numArgs = len(argv)
	else:
		assignHardValues()

	if values.get('-appName') != "" and values.get('-pathToIPA') != "" and values.get('-pathToIcon') != "":
		hasAppData = True
	if values.get('-provisionProfName') != "" and values.get('-pathToProvisionProfile') != "":
		hasProvProfData = True
		
	if hasProvProfData == True and hasAppData == True: # Submitting mobile app & Provisioning Profile	
		if testConn():
			log("Submitting mobile app and Provisioning Profile...")
			# Check Provisioning Profile and upload accordingly
			exists = checkForExistingProfile()
			if not exists:
				uploadProfile()
			
			# Check mobile app and upload accordingly
			appExists = checkForExistingApp()
			uploadAppMetaData(appExists)
			mobileAppID = findAppID(values.get('-appName'))
			uploadAppIcon(mobileAppID)
			uploadAppIPA(mobileAppID)
		else:
			log('Connection to JSS failed. Please check your credentials.')
			sys.exit()
		
	elif hasProvProfData == False and hasAppData == True: # Submitting mobile app
		if testConn():
			log("Submitting mobile app...")
			# Check mobile app and upload accordingly
			appExists = checkForExistingApp()
			uploadAppMetaData(appExists)
			mobileAppID = findAppID(values.get('-appName'))
			uploadAppIcon(mobileAppID)
			uploadAppIPA(mobileAppID)
		else:
			log('Connection to JSS failed. Please check your credentials.')
			sys.exit()
			
	elif hasProvProfData == True and hasAppData == False: # Submitting Provisioning Profile
		if testConn():
			log("Submitting Provisioning Profile...")
			
			# Check Provisioning Profile and upload accordingly
			exists = checkForExistingProfile()
			if not exists:
				uploadProfile()
		else:
			log('Connection to JSS failed. Please check your credentials.')
			sys.exit()
			
	elif argv[0] == "-h" or argv[0] == "-help" or argv[0] == "help":
		help()

def checkForExistingProfile():
	global values, profile
	try: 
		log("Checking if the profile already exists...")
		#See if the profile name already exist
		conn = httplib.HTTPSConnection(values.get("-jssHost"),values.get("-jssPort"))
		headers = {"Authorization":getAuthHeader(values.get("-jssUser"),values.get("-jssPass")),"Accept":"text/xml"}
	    #Convert the string to a URL friendly syntax ("%20" instead of a " ", etc.)
		path = ""
		if values.get('-jssPath' ) != None:
			path = values.get('-jssPath' )
		url = convertStringToURL(path + "/JSSResource/mobiledeviceprovisioningprofiles/name/" + values.get("-provisionProfName"))
		conn.request("GET",url,None,headers)
		response = conn.getresponse()
		xmldata = response.read()
		stat = response.status #works
		conn.close()
	
		if stat == 200:
			profile.name = parseXML(xmldata, "display_name")
			profile.id = parseXML(xmldata, "id")
			profile.uuid = parseXML(xmldata, "uuid")
			log("\tProfile exists. Using existing profile \"" + profile.name + "\"...")
			return True
		else:
			return False
		
	except urllib2.HTTPError as inst:
		log("Exception occurred: %s" % inst)
  
def uploadProfile():
	global values, profile
	log("Uploading Provisioning Profile...")
	if profile.name is None:
		prov_profile_name = cleanForXML(values.get("-provisionProfName"))
		#Open File and Convert to Base64
		profileContent = open(values.get("-pathToProvisionProfile")).read().encode("base64")
		#Get the file name of the profile based on the full path
		profileFileName = os.path.basename(values.get("-pathToProvisionProfile"))	
		#Read in the UUID of the profile
		profileUUID = commands.getoutput("cat -v \"" + values.get("-pathToProvisionProfile") + "\" | grep -A 1 UUID | grep string | sed 's:<string>::g' | sed 's:</string>::g' | awk '{print $1}'")
	else:
		prov_profile_name = cleanForXML(profile.name)
		profileUUID = profile.uuid
		profileContent = open(values.get("-pathToProvisionProfile")).read().encode("base64")
		profileFileName = os.path.basename(values.get("-pathToProvisionProfile"))
		
	path = ""
	if values.get('-jssPath' ) != None:
		path = values.get('-jssPath' )

	url = "https://" + str(values.get("-jssHost")) + ":" + str(values.get("-jssPort")) + path + "/JSSResource/mobiledeviceprovisioningprofiles/id/0"
	#Write out the XML string with new data to be submitted
	newDataString = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?><mobile_device_provisioning_profile><general><id/><display_name>" + prov_profile_name + "</display_name><uuid>" + profileUUID + "</uuid><profile><name>" + profileFileName + "</name><uri/><data>" + profileContent + "</data></profile></general></mobile_device_provisioning_profile>"
	#print newDataString
	try:
		opener = urllib2.build_opener(urllib2.HTTPHandler)
		request = urllib2.Request(url,newDataString)
		request.add_header("Authorization", getAuthHeader(values.get("-jssUser"),values.get("-jssPass")))
		request.add_header('Content-Type', 'application/xml')
		request.get_method = lambda: 'POST'
		opener.open(request)
		
		if profile.name is None:
			checkForExistingProfile()
	except urllib2.HTTPError as inst:
		log("Exception occurred: %s" % inst)
	except:
		log("An error occurred uploading provisioning profile.")

         
def checkForExistingApp():
	global values
	log("Checking if the app already exists...")
	try:
		conn = httplib.HTTPSConnection(values.get("-jssHost"),values.get("-jssPort"))
		headers = {"Authorization":getAuthHeader(values.get("-jssUser"),values.get("-jssPass")),"Accept":"text/xml"}
		
		path = ""
		if values.get('-jssPath' ) != None:
			path = values.get('-jssPath' )
	
		url = convertStringToURL(path + "/JSSResource/mobiledeviceapplications/name/" + values.get("-appName"))
		conn.request("GET",url,None,headers)
	    #Get xml list of apps from JSS
		xmldata = conn.getresponse().read()
		conn.close()
	
		if "<html>" in xmldata:
			log("\tApp does not exist")
			return False
		else:
			log("\tApp exists.  Existing app will be updated.")
			return True
		
	except urllib2.HTTPError as inst:
		log("HTTP Exception Occurred: " + str(inst))
       
def uploadAppIPA(mobileAppID):
	global values
	
	try:
		if os.path.exists(values.get('-pathToIPA')):
			path = ""
			if values.get('-jssPath' ) != None:
				path = values.get('-jssPath' )
				
			log("Updating mobile app IPA for app " + values.get('-appName'))
			results = commands.getoutput("curl -v -k -u " + values.get("-jssUser") + ":" + values.get("-jssPass") + " https://" + values.get("-jssHost") + ":" + str(values.get("-jssPort")) + path + "/JSSResource/fileuploads/mobiledeviceapplicationsipa/id/" + mobileAppID + " -F name=@" + values.get("-pathToIPA") + " -X POST ")
			
			if "201 Created" in results:
				log("\tUploaded mobile app IPA \"" + values.get('-appName') + "\" successfully.")
			else:
				m = re.compile('<p.*?>(.*?)</p>', re.DOTALL).findall(results[2470:])
				log("\tError uploading mobile app IPA: " + m[0] + " - " + m[1]) 
	
		else:
			log('Could not update mobile app. The -pathToIPA value could not be evaluated.')
			
	except Exception as inst:
	 	log("An error occurred updating mobile app IPA: " + str(inst))
	
def uploadAppIcon(mobileAppID):
	global values
	
	try:
		if os.path.exists(values.get('-pathToIcon')):
			
			path = ""
			if values.get('-jssPath' ) != None:
				path = values.get('-jssPath' )
			
			log("Updating mobile app icon for app " + values.get('-appName'))
			results = commands.getoutput("curl -k -v -u " + values.get("-jssUser") + ":" + values.get("-jssPass") + " https://" + values.get("-jssHost") + ":" + str(values.get("-jssPort")) + path + "/JSSResource/fileuploads/mobiledeviceapplicationsicon/id/" + mobileAppID + " -F name=@" + values.get("-pathToIcon") + " -X POST ")
	
			if "201 Created" in results:
				log("\tUploaded mobile app icon \"" + values.get('-appName') + "\" successfully.")
			else:
				m = re.compile('<p.*?>(.*?)</p>', re.DOTALL).findall(results)
				log("\tError uploading mobile app icon: " + m[0] + " - " + m[1]) 
			
		else:
			log('Could not update mobile app. The -pathToIcon value could not be evaluated.')
			
	except Exception as inst:
		log("An error occurred updating mobile app icon: " + str(inst))

def uploadAppMetaData(appExists):
	global values
	newDataString = None
	
	# Determining XML data
	if appExists:
		newDataString = str(createMetaDataXML('PUT'))
	else:
		newDataString = str(createMetaDataXML('POST'))
		
	path = ''
	if values.get('-jssPath' ) != None:
		path = values.get('-jssPath' )
	url = "https://" + str(values.get("-jssHost")) + ":" + str(values.get("-jssPort")) + path + "/JSSResource/mobiledeviceapplications/name/" + convertStringToURL(values.get('-appName'))

	try:
	    opener = urllib2.build_opener(urllib2.HTTPHandler)
	    request = urllib2.Request(url,newDataString)
	    request.add_header("Authorization", getAuthHeader(values.get("-jssUser"),values.get("-jssPass")))
	    request.add_header('Content-Type', 'application/xml')

	    if appExists:
	        #Update existing app
	        request.get_method = lambda: 'PUT'
	        log("Updating mobile app meta data...")

	    else:
	        #Create new app
	        request.get_method = lambda: 'POST'
	        log("Uploading mobile app meta data...")
	        
	    signal.signal(signal.SIGPIPE, signal.SIG_DFL)
	    opener.open(request)
	except urllib2.HTTPError as inst:
		log("Exception Occurred: " + str(inst))
	except Exception as inst:
		log ("An error occurred uploading mobile device meta data: " + str(inst))

## HELPER FUNCTIONS ##

def assignParamValues():
	global values, hostParams, appParams, appOptions, profileParams
	
	values = {}
	params = hostParams + appParams + appOptions + profileParams
	
	counter = 0
	while argv and (counter < len(argv) - 1): 
		if argv[counter][0] == '-': 
			try:
				if isinstance(params.index(argv[counter]), int): # Check if param exists
					values[argv[counter]] = argv[counter + 1] 
					#log("Assigned " + argv[counter] + "=" + argv[counter + 1])

			except:
				# If user provides a different parameter name then the script will display help message and exist script
				print "\n\tYou have provided an erroneous parameter: " + argv[counter] + "."
				print "\tPlease check your spelling or check below for correct parameter name.\n"
				
				help()
				sys.exit()
		
		counter = counter + 1

def assignHardValues():	
	global jss_host, jss_port, jss_path, jss_username, jss_password, name, description, bundle_id, version, app_meta_data, path_to_ipa, path_to_icon, prov_profile_name, prov_profile_path, internal_app, auto_deploy_app, deploy_as_managed_app, remove_app_with_MDMProf, prevent_app_databackup, free_app
	global values
	log("Did not detect parameters. Attempting to use hard coded values...")
	verifyVariable("jss_host", jss_host)
	verifyVariable("jss_port", jss_port)
	verifyVariable("jss_username", jss_username)
	verifyVariable("jss_password", jss_password)
	verifyVariable("name", name)
	verifyVariable("bundle_id", bundle_id)
	verifyVariable("version", version)
	verifyVariable("app_meta_data", app_meta_data)
	verifyVariable("path_to_ipa", path_to_ipa)
	verifyVariable("path_to_icon", path_to_icon)
	verifyVariable("internal_app", internal_app)
	verifyVariable("auto_deploy_app", auto_deploy_app)
	verifyVariable("deploy_as_managed_app", deploy_as_managed_app)
	verifyVariable("remove_app_with_MDMProf", remove_app_with_MDMProf)
	verifyVariable("prevent_app_databackup", prevent_app_databackup)
	verifyVariable("free_app", free_app)
	values = {'-jssHost':jss_host,'-jssPort':jss_port,'-jssPath':jss_path,'-jssPass':jss_password,'-jssUser':jss_username,'-appName':name,'-appDesc':description,'-appBundleID':bundle_id,'-appVersion':version,'-pathToIPA':path_to_ipa,'-pathToIcon':path_to_icon, '-provisionProfName':prov_profile_name, '-pathToProvisionProfile':prov_profile_path,'-internalApp':internal_app,'-autoDeployApp':auto_deploy_app,'-deployAsManagedApp':deploy_as_managed_app,'-removeAppWithMDMProf':remove_app_with_MDMProf,'-preventAppDataBackup':prevent_app_databackup,'-freeApp':free_app}

def verifyVariable(name, value):
    if value == "":
        log("Error: Please specify a value for variable \"" + name + "\"")
        help()
        sys.exit(1)
			
def help():
	print "\n\tHelp:"
	print "\t\tJSS information is required on every upload whether uploading a Mobile Device App or Provisioning Profile."
	print "\t\tYou can optionally choose to upload a Mobile Device App and Provisioning Profile or either one.\n"
	print "\tRequired:"
	print "\t\t-jssHost [jssAddress] -jssPath [jss path] -jssPort [port] -jssUser [username] -jssPass [password]\n"
	print "\tMobile Device App:"
	print "\t\t-appName [name] -appDesc [description] -appBundleID [bundle_id] -appVersion [version]\n\t\t-pathToIPA [path_to_ipa] -pathToIcon [path_icon]\n"
	print "\tMobile Device App Options:"
	print "\t\t-internalApp [true/false] -autoDeployApp [true/false] -deployAsManagedApp [true/false] -removeAppWithMDMProf [true/false]\n\t\t-preventAppDataBackup [true/false] -freeApp [true/false]\n"
	print "\tProvisioning Profile:"
	print "\t\t-provisionProfName [provision_profile_name] -pathToProvisionProfile [provision_profile_path]\n"
		
def findAppID(appname):
	global values
	log("Looking for mobile app ID...")
	conn = httplib.HTTPSConnection(values.get('-jssHost'),values.get('-jssPort'))
	headers = {"Authorization":getAuthHeader(values.get('-jssUser'),values.get('-jssPass')),"Accept":"text/xml"}
    #Convert the string to a URL friendly syntax ("%20" instead of a " ", etc.)
	try:	
		if appname != None:
			path = ""
			if values.get('-jssPath' ) != None:
				path = values.get('-jssPath' )
						
			url = convertStringToURL(path + "/JSSResource/mobiledeviceapplications")
			conn.request("GET",url,None,headers)
			xmldata = conn.getresponse().read()
			conn.close()
			xmldoc = minidom.parseString(xmldata)
			names = xmldoc.getElementsByTagName("display_name")
			id = None
			for name in names:
				if re.sub('<(?!(?:a\s|/a|!))[^>]*>','',name.toxml()) == appname:
					id = re.sub('<(?!(?:a\s|/a|!))[^>]*>','',name.parentNode.firstChild.toxml())
					log("Found ID " + str(id) + " for " + appname + ".")
			
			return id
		else:
			log("The provided app name is null.")
			
	except urllib2.HTTPError as inst:
		log("\tYou provided incorrect authentication.")
		sys.exit()

def testConn():
	global values
	log('Testing JSS connection...')
	path = ""
	if values.get('-jssPath' ) != None:
		path = values.get('-jssPath' )
	url = values.get('-jssHost') + path
	conn = httplib.HTTPSConnection(url, values.get('-jssPort'))
	headers = {"Authorization":getAuthHeader(values.get('-jssUser'),values.get('-jssPass'))}
	conn.request("GET", "/JSSResource/mobiledeviceapplications", "",headers)
	response = conn.getresponse()
 	if response.reason == 'Unauthorized':
 		log("Return code from JSS: " + str(response.status) + " " + response.reason)
 		return False
 	else:
 		return True

def getAuthHeader(u,p):
    # Compute base64 representation of the authentication token.
    token = base64.b64encode('%s:%s' % (u,p))
    return "Basic %s" % token

def convertStringToURL(string):
    url = urllib2.quote(string)
    return url

def parseXML(xmldata, tagName):
    values=[];
    cleanedValues=[];
    data = None
    xmldoc = minidom.parseString(xmldata)
    values = xmldoc.getElementsByTagName(tagName)
    if values:
		for index, value in enumerate(values):
			cleanedValue = re.sub('<(?!(?:a\s|/a|!))[^>]*>','',value.toxml())
			cleanedValues.append(cleanedValue)
		#Return the first match
		data = cleanedValues[0]
		return data

def cleanForXML(value):
    value = str(value).replace("&", "&amp;")
    value = str(value).replace("<", "&lt;")
    value = str(value).replace(">", "&gt;")
    return value

def createMetaDataXML(method):
	global values, profile

	log("Creating mobile app meta data XML...")
	metaValues = {'internal_application':values.get('-internalApp'),'deploy_automatically':values.get('-autoDeployApp'),'deploy_as_managed_app':values.get('-deployAsManagedApp'),'remove_app_when_mdm_profile_is_removed':values.get('-removeAppWithMDMProf'),'prevent_backup_of_app_data':values.get('-preventAppDataBackup'),'free':values.get('-freeApp')}
	appValues = {'display_name':values.get('-appName'),'description':values.get('-appDesc'),'bundle_id':values.get('-appBundleID'),'version':values.get('-appVersion')}
	profileValues = {'id' : profile.id, 'uuid' : profile.uuid, 'display_name' : profile.name}

	xmlImpl = minidom.getDOMImplementation()
	doc = xmlImpl.createDocument(None, None, None)
	mobDevApp = doc.createElement("mobile_device_application")
	doc.appendChild(mobDevApp)
	gen = doc.createElement("general")
	mobDevApp.appendChild(gen)
	
	for k in appValues:
		if appValues.get(k) != None:
			elem = doc.createElement(str(k))
			gen.appendChild(elem)
			text = doc.createTextNode(str(appValues.get(k)))
			elem.appendChild(text)
		
	for k in metaValues:
		if metaValues.get(k) != None: 
			elem = doc.createElement(str(k))
			gen.appendChild(elem)
			text = doc.createTextNode(str(metaValues.get(k)).lower())
			elem.appendChild(text)
	
	if hasProvProfData:
		profileElem = doc.createElement("provisioning_profile")
		gen.appendChild(profileElem)
		for k, v in profileValues.iteritems():
			elem = doc.createElement(str(k))
			text = doc.createTextNode(str(v))
			elem.appendChild(text)
			profileElem.appendChild(elem)
			
	scopeElem = doc.createElement("scope")
	allMobileElem = doc.createElement("all_mobile_devices")
	scopeElem.appendChild(allMobileElem)
	text = doc.createTextNode("true")
	allMobileElem.appendChild(text)
	mobDevApp.appendChild(scopeElem)
						
	#print doc.toprettyxml(indent="	", encoding="UTF8")
	return doc.toprettyxml(indent="	", encoding="UTF8")

def log(logText):
    if interactiveLogMode == True:
        print logText
    logFormat = "%(asctime)s - %(name)s - %(message)s"
    try:
        logging.basicConfig(filename=logFile, level=logging.INFO, format=logFormat)
        logging.info(logText)
    except IOError as inst:
        print "\tAn IO Error occurred logging" + str(inst) + ".  \n\tContinuing without logging."
    except:
        print "\tAn unknown error ocurred logging"
        
        
        
if __name__ == "__main__":
	initAll()
	
