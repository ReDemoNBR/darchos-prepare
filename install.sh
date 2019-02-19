#!/bin/bash

function help() {
    echo -e "Usage:\n\
\tbash install.sh [-nw] [-(d|D) DEVICE] [-m MOUNT_POINT] [-t TMP_PATH]\n\
\n\
OPTIONS:\n\
  -d DEVICE\tskip the device selection prompts using the given DEVICE\n\
  -D DEVICE\tjust like -d option, but doesn't ask for confirmation. Overrides -d option\n\
  -h\t\tshow this help text\n\
  -m PATH\tpath for mounting point for the partitions. Defaults to '/mnt'. Use absolute path\n\
  -n\t\tdoes not remove ArchLinuxARM files. Useful for testing to avoid downloading ArchLinuxARM again if it's already there. Use -nn for not removing any file\n\
  -t PATH\tpath for downloading temporary files. Defaults to '/tmp'. Use absolute path\n\
  -w\t\tuse wip (work-in-progress) branch, which might include fresh features, but is unstable. Useful for collaborators and developers."
  exit 0
}

function error(){
    echo -e $1
    exit 1
}


[[ -n $( echo "$@" | grep --perl-regexp "(^|\s)--help($|\s)" ) ]] && help

function run() {
    cd "$path_here"
    bash "${path_here}/install.d/${1}.sh"
    [[ $? -ne 0 ]] && exit 1
}

while getopts ":d:D:m:nt:wh" option; do
    case $option in
        d)
            DEVICE="$OPTARG"
            ;;
        D)
            DEVICE="$OPTARG"
            DEVICE_FORCE=1
            ;;
        h)
            help
            ;;
        m)
            MOUNT_POINT="$OPTARG"
            [[ ! -d $MOUNT_POINT ]] && error "Error in -m option:\n\tMounting point must be a valid directory"
            ;;
        n)
            [[ $NO_REMOVE_ARCH -eq 1 ]] && NO_REMOVE_DARCHOS=1
            NO_REMOVE_ARCH=1
            ;;
        t)
            TMP_PATH="$OPTARG"
            [[ ! -d $TMP_PATH ]] && error "Error in -t option:\n\tTemporary folder must be a valid directory"
            ;;
        w)
            BRANCH="wip"
            ;;
        :)
            error "Missing argument in -$OPTARG"
            ;;
        ?)
            error "Invalid option -$OPTARG"
            ;;
    esac
done

## Change to "this" directory (the root of darchos-script)
cd "$( dirname "$( pwd -P )/$0" )"
path_here=$(pwd)

## contants
source ./config.txt

## functions
source lib/prompt.sh

run "errors"

echo -e "\
MOUNT_POINT=\"${MOUNT_POINT:="/mnt"}\"\n\
TMP_PATH=\"${TMP_PATH:="/tmp"}\"\n\
BRANCH=\"${BRANCH:="master"}\"\n\
ARCH=\"${ARCH}\"\n\
NO_REMOVE_ARCH=\"${NO_REMOVE_ARCH}\"\n\
NO_REMOVE_DARCHOS=\"${NO_REMOVE_DARCHOS}\"" > conf/conf.tmp

if [[ -z $DEVICE ]]; then
    run "select-device"
    run "confirm-device"
    source ./conf/block.tmp                 ## provides $DEVICE variable after user had selected the device to format
else
    if [[ -z $( lsblk --output model --nodeps --noheading $DEVICE | grep SD_MMC ) ]]; then
        echo "$DEVICE is not a microSD card"
        exit 1
    fi
    if [[ -z $DEVICE_FORCE ]]; then
        lsblk $DEVICE
        echo "DEVICE=\"$DEVICE\"" > "${path_here:?}/conf/block.tmp"
        run "confirm-device"
    else
        echo "DEVICE=\"$DEVICE\"" > "${path_here:?}/conf/block.tmp"
    fi
fi

run "format-sdcard"
run "mount-partitions"
run "install-arch"
run "download-darchos-resources"

# Create a script to run Darchos setup script to prepare the environment on the first boot
# (it will remove itself after it ran successfully)
run "prepare-darchos"

run "add-configs"
echo "MicroSD is prepared for DArchOS to complete installation when it boots up"
run "unmount-partitions"
run "wrapup"

echo "Now connect the microSD to a Raspberry Pi 2/3 and apply the 5V power to finish the installation"
