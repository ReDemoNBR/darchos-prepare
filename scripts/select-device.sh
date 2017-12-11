#!/bin/bash

file="conf/block.tmp"

[[ -f $file ]] && rm "$file"

# ask which one to start formating
blocks=$(lsblk --paths --output name,size,model --nodeps | grep SD/MMC)
sdcards=()
for block in $blocks ; do
    sd=$( echo $block | cut --delimiter ' ' --fields 1)
    if [[ -n $( echo "$sd" | grep '/dev/' ) ]]; then
        sdcards+=("$sd")
    fi
done
sdcards_string=$( printf "' | '%s" "${sdcards[@]}" )
sdcards_string="${sdcards_string:4}'"
lsblk --paths --output name,fstype,label,size,vendor --tree --perms "${sdcards[@]}"
echo -e "Type the name of the block device to format or 'exit' to quit\nOptions: ($sdcards_string)"
read block

if [[ "$block" == "exit" ]]; then
    echo "Canceling by user request"
	exit 1
elif [[ "$block" != /dev/* ]]; then
    block="/dev/$block"
fi

if [[ -z "$block" || -z $( printf -- "%s\n" "${sdcards[@]}" | grep --line-regexp "$block" ) ]]; then
	echo -e "$block is not a SD/MMC block\n"
	bash $0
	exit $?
fi

# warns the user that this might screw his system if he formats the wrong partition
confirm=""
while [[ -z $( echo "yes no" | grep --word-regexp "$confirm" ) ]]; do
	echo -n "Are you sure '$block' is the correct device to format? (yes/no): "
	read confirm
done
if [[ "$confirm" == "no" ]]; then
	bash $0
	exit $?
fi

confirm=""
while [[ -z $( echo "yes no exit" | grep --word-regexp $confirm ) ]]; do
	echo "FORMATING A DEVICE WILL ERASE EVERY DATA AND FILE IT CONTAINS"
	echo -n "ARE YOU REALLY SURE YOU WANT TO CONTINUE? (yes/no/exit): "
	read confirm
done
if [[ "$confirm" == "exit" ]]; then
    echo -e "\n"
	exit 1
elif [[ "$confirm" == "no" ]]; then
	bash $0
	exit $?
fi

echo "DEVICE=\"$block\"" > $file
