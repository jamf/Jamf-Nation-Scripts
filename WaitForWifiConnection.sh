#!/bin/sh

NetworkAdapters=$(networksetup -listallhardwareports | grep -i -a "Wi-Fi" -A 1 | grep -i -a "Device:")
WiFiAdapter=${NetworkAdapters#* }

WiFiConnection=$(networksetup -getairportnetwork en0 | grep -i -a "Current Wi-Fi Network:")

while [ "$WiFiConnection" == "" ]
do
  WiFiConnection=$(networksetup -getairportnetwork en0 | grep -i -a "Current Wi-Fi Network:")
done

echo “Wi-Fi is now connected”
