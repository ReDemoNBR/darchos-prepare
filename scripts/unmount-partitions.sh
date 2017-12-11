#!/bin/bash

## messages
source lib/message.sh

## variables
source conf/conf.tmp

init "Unmounting microSD"
umount "${MOUNT_POINT:?}/boot" "${MOUNT_POINT:?}/root"
rm --recursive --force "${MOUNT_POINT:?}/boot" "${MOUNT_POINT:?}/root"
end