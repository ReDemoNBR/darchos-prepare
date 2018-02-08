#!/bin/bash

## functions
source lib/prompt.sh

file="conf/block.tmp"

[[ -f $file ]] && rm "$file"

# ask which one to start formating
blocks=$( lsblk --paths --output name,size,model --nodeps | grep SD/MMC )
sdcards=()
for block in $blocks; do
    sd=${block%% *}
    [[ -n $( echo "$sd" | grep '/dev/' ) ]] && sdcards+=("$sd")
done
pick -nqt "Select the block device to format" -O "${sdcards[*]}" -v block
if [[ "$block" == "quit" ]]; then
    echo "Canceling by user request"
    exit 1
fi

echo "DEVICE=\"$block\"" > $file
