#!/bin/sh
#	install location: /usr/local/bin

#	This script was written to interrogate a package file for its internal
#	file name and version number. This can be helpful when a package file 
#	no longer retains its original file name or outwardly identifies its 
#	version number. 

#	Author:		Andrew Thomson
#	Date:		05-23-2016

#	Use the following syntax to interrogate all the packages in a folder
#	for PKGS in /path/to/packages/*.pkg; do pkgver "$PKGS"; done

#	RESOURCES:
#	http://stackoverflow.com/questions/11298855/how-to-unpack-and-pack-pkg-file
#	http://www.mactech.com/articles/mactech/Vol.26/26.02/TheFlatPackage/index.html

FILE_PATH="$1"
FILE_NAME="${FILE_PATH##*/}"
PKG_PATH="${FILE_PATH%/*}"
TMP_PATH=`/usr/bin/mktemp -d /tmp/PKGINFO.XXXX`
DEBUG=false


#	verify file exists and is of type pkg
if [ ! -f "$FILE_PATH" ] || [ "$FILE_NAME##*." == "pkg" ]; then
	echo "ERROR: Unable to find valid package file."
	echo "USAGE: ${0##*/} /path/to/package"
	exit $LINENO
fi


#	display variable in debug mode
if $DEBUG; then 
	echo "FILE:   $FILE_NAME"
	echo "FOLDER: $PKG_PATH"
	echo "TEMP:   $TMP_PATH"
fi


#	get package title
PKG_TITLE=`/usr/sbin/installer -verbose -pkginfo -pkg "$FILE_PATH" | /usr/bin/grep -m 1 Title | /usr/bin/awk -F " : " '{print $2}'`


#	get paths of PackageInfo files
if ! PKG_INFO=(`/usr/bin/xar -t -f "$FILE_PATH" | /usr/bin/grep PackageInfo`); then 
	echo "ERROR: Unable to find package file information."
	exit $LINENO
fi


#	change to temp folder
pushd "$TMP_PATH" > /dev/null


#	extract each PackageInfo file to temp location
for PKG_FILE in ${PKG_INFO}; do
	if ! /usr/bin/xar -x -f "$FILE_PATH" "$PKG_FILE"; then
		echo "ERROR: Unable to extract package file information."
		exit $LINENO
	else
		TMP_INFO+=("$TMP_PATH/$PKG_FILE")
		if $DEBUG; then echo "INFO:   ${TMP_INFO[@]}"; fi
	fi
done


#	read each PackageInfo file to extract info
for FILE_INFO in $TMP_INFO; do
	PKG_VERSION+=(`/usr/bin/xpath "$FILE_INFO" "string(/pkg-info[1]/@version)" 2> /dev/null`)
	echo "TITLE:   $PKG_TITLE"
	echo "VERSION: ${PKG_VERSION[@]}"
done


#	change back to original folder
popd > /dev/null


#	remove tmp files
/bin/rm -rf "$TMP_PATH"