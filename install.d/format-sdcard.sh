#!/bin/bash

## messages
source lib/message.sh

## variables
source conf/block.tmp


echo "Preparing to format $DEVICE"
sleep 5

if [[ -z $DEVICE ]]; then
    echo "block device was not found"
    exit 1
fi
if [[ ! -b $DEVICE ]]; then
    echo "$DEVICE is not a block device"
    exit 1
fi
if [[ -z $( lsblk --output model --nodeps --noheading $DEVICE | grep SD_MMC ) ]]; then
    echo "$DEVICE is not a microSD card"
    exit 1
fi
for mountpoint in $( lsblk --noheading --output mountpoint $DEVICE ); do
    init "Unmounting $mountpoint"
    umount $mountpoint
    end
done

# Clear all partitions in SDcard
partitions=$(parted -s "$DEVICE" print | awk '/^ / {print $1}')
for partnum in $partitions; do
    init "Removing partition number $partnum from $DEVICE"
    parted -s "$DEVICE" rm "$partnum" &> /dev/null
    if [[ $? -ne 0 ]]; then
        end "fail"
        exit 1
    fi
    end
done

init "Creating FAT16 partition with 100MB for booting"
# Create FAT16 partition with 100MB for "/boot" and format it
parted -s "$DEVICE" mkpart primary fat16 1MiB 101MiB &> /dev/null
if [[ $? -ne 0 ]]; then
    end "fail"
    exit 1
fi
mkfs.fat -F16 -v -I -n "BOOT" "${DEVICE}1" &> /dev/null
if [[ $? -ne 0 ]]; then
    end "fail"
    exit 1
fi
end

init "Creating EXT4 partition with the rest of the microSD card for root files"
# Create ext4 partition with the rest of its size for "/" and format it
parted -s "$DEVICE" mkpart primary ext4 101MiB 100% &> /dev/null
if [[ $? -ne 0 ]]; then
    end "fail"
    exit 1
fi
mkfs.ext4 -F -O ^64bit -L "root" "${DEVICE}2" &> /dev/null
if [[ $? -ne 0 ]]; then
    end "fail"
    exit 1
fi
end
