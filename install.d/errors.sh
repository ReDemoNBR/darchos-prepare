#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "must run as root"
    exit 1
fi

if [[ ! -f config.txt ]]; then
    echo "couldn't find config.txt"
    exit 1
fi


required_commands=(bsdtar cp curl lsblk mkdir mkfs.ext4 mkfs.fat mount mv parted rm sleep sync umount)
for req_com in "${required_commands[@]}"; do
    if [[ -z $( type -P $req_com ) ]]; then
        echo "$req_com is required, but not installed"
        exit 1
    fi
done

if [[ -z $( lsblk -o name,size,model | grep SD/MMC ) ]]; then
    echo "no SD/microSD card detected"
    exit 1
fi
