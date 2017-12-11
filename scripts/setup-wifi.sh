#!/bin/bash

## messages
source lib/message.sh

## variables
source config.txt
source conf/conf.tmp

wifi_conf="${MOUNT_POINT:?}/root/etc/netctl/wifi"

init "Setting up wifi configuration for Raspberry Pi"
## copies the original file
cp "${MOUNT_POINT:?}/root/etc/netctl/examples/wireless-wpa" "$wifi_conf"
sed --in-place "s/ESSID='MyNetwork'/ESSID='${WIFI_SSID}'/g" "$wifi_conf"
sed --in-place "s/Key='WirelessKey'/Key='${WIFI_PASS}'/g" "$wifi_conf"
end

echo "Wifi configuration up"