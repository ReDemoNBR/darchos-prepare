#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "must run as root"
    exit 1
fi

if [[ ! -f config.txt ]]; then
    echo "couldn't find config.txt"
    exit 1
fi

if [[ -z $(lsblk -o name,size,model | grep SD/MMC) ]]; then
    echo "no SD/microSD card detected"
    exit 1
fi

if [[ -z $( type -p parted ) ]]; then
    echo "parted is not installed"
    exit 1
fi
