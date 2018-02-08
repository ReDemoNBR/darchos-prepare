#!/bin/bash

## constants
source conf/block.tmp

## functions
source lib/prompt.sh

[[ -z $DEVICE ]] && exit 1

## options
cancel="No, cancel and quit"
select_another="No, I will pick another block to format"
yes="Yes, format $DEVICE"
pick -nt "Formating will erase every data it contains! Do you wish to format '${DEVICE}'?" -o "$cancel" -o "$select_another" -o "$yes" -v confirm
if [[ "$confirm" == "$cancel" ]]; then
    echo "Canceling by user request"
    rm conf/*.tmp
    exit 1
elif [[ "$confirm" == "$select_another" ]]; then
    bash $0
    exit $?
fi

echo "DEVICE=\"${DEVICE}\"" > conf/block.tmp
