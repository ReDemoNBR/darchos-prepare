#!/bin/bash

## messages
source lib/message.sh

## variables
source conf/conf.tmp
source conf/urls.conf


cd "$TMP_PATH"
filename="${ARCH_FILE##*/}"
if [[ ! -f "${TMP_PATH}/$filename" ]]; then
    echo "Downloading base ArchLinuxARM:"
    curl -Lo "$filename" "$ARCH_FILE"
    if [[ $? -ne 0 ]]; then
        echo "Could not download ArchLinuxARM from official repository"
        exit 1
    fi
else
    echo "File $filename already found in ${TMP_PATH}, so will use it as base ArchLinuxARM"
fi

init "Extracting $filename"
bsdtar -xpf "$filename" -C "${MOUNT_POINT:?}/root/" &> /dev/null
sync
end

init "Moving /boot to FAT16 partition for better compatibility and faster booting"
mv "${MOUNT_POINT:?}/root/boot/"* "${MOUNT_POINT:?}/boot/"
sync
end

if [[ -z $NO_REMOVE_ARCH ]]; then
    init "Removing $filename"
    rm "${TMP_PATH:?}/$filename"
    end
fi

echo "ArchLinuxARM installed successfully"