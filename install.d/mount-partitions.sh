#!/bin/bash

## messages
source lib/message.sh

## variables
source conf/block.tmp
source conf/conf.tmp

init "Mounting microSD's '/boot' and '/' partitions in $MOUNT_POINT"
mkdir --parents "${MOUNT_POINT:?}/boot" "${MOUNT_POINT:?}/root"
mount "${DEVICE:?}1" "${MOUNT_POINT:?}/boot/"
mount "${DEVICE:?}2" "${MOUNT_POINT:?}/root/"
end