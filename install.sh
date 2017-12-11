#!/bin/bash
function help() {
    echo -e "Usage:\n\
\tbash install.sh [OPTIONS]\n\
\n\
OPTIONS:\n\
  -d DEVICE\tskip the device selection prompts using the given DEVICE - Warning: this option formats any block device, including hard drives (use it wisely)\n\
  -D DEVICE\tjust like -d option, but doesn't ask for confirmation\n\
  -h\t\tshow this help text\n\
  -m PATH\tpath for mounting point for the partitions. Defaults to '/mnt'. Use absolute path\n\
  -n\t\tdoes not remove ArchLinuxARM files. Useful for testing to avoid downloading ArchLinuxARM again if it's already there\n\
  -N\t\tdoes not remove any downloaded file. Useful for testing to avoid downloading files again if they are already there\n\
  -t PATH\tpath for downloading temporary files. Defaults to '/tmp'. Use absolute path\n\
  -w\t\tuse wip (work-in-progress) branch, which might include fresh features, but is unstable. Useful for collaborators and developers."
}

function run() {
    cd "$path_here"
    bash "${path_here}/scripts/${1}.sh"
    [[ $? -ne 0 ]] && exit 1
}

while getopts ":d:D:m:nNt:wh" option; do
    case $option in
        d)
            DEVICE=$OPTARG >&2
            ;;
        D)
            DEVICE=$OPTARG >&2
            DEVICE_FORCE=1
            ;;
        h)
            help
            exit 0
            ;;
        m)
            MOUNT_POINT=$OPTARG >&2
            if [[ ! -d $MOUNT_POINT ]]; then
                echo -e "Error in -m option:\n\tMounting point must be a valid folder"
                exit 1
            fi
            ;;
        n)
            NO_REMOVE_ARCH=1 >&2
            ;;
        N)
            NO_REMOVE_ARCH=1 >&2
            NO_REMOVE_DARCHOS=1 >&2
            ;;
        t)
            TMP_PATH=$OPTARG >&2
            if [[ ! -d $TMP_PATH ]]; then
                echo -e "Error in -t option:\n\tTemporary folder must be a valid folder"
                exit 1
            fi
            ;;
        w)
            BRANCH="wip" >&2
            ;;
        \?)
            echo "Invalid option -$OPTARG" >&2
            ;;
    esac
done

MOUNT_POINT=${MOUNT_POINT:-"/mnt"}
TMP_PATH=${TMP_PATH:-"/tmp"}
BRANCH=${BRANCH:-"master"}

## Change to "this" directory (the root of darchos-script)
cd "$( dirname "$( pwd -P )/$0" )"
path_here=$(pwd)
source ./config.txt

run "errors"

echo -e "\
MOUNT_POINT=\"${MOUNT_POINT}\"\n\
TMP_PATH=\"${TMP_PATH}\"\n\
BRANCH=\"${BRANCH}\"\n\
NO_REMOVE_ARCH=\"${NO_REMOVE_ARCH}\"\n\
NO_REMOVE_DARCHOS=\"${NO_REMOVE_DARCHOS}\"" > conf/conf.tmp

if [[ -z $DEVICE ]]; then
    run "select-device"
    source ./conf/block.tmp                 ## provides $DEVICE variable after user had selected the device to format
elif [[ -z $DEVICE_FORCE ]]; then
    if [[ -z $( lsblk --output model --nodeps --noheading $DEVICE | grep SD/MMC ) ]]; then
        echo "$DEVICE is not a microSD card"
        exit 1
    fi
    while [[ -z $( echo "yes no exit" | grep --word-regexp $confirm ) ]]; do
        lsblk $DEVICE
    	echo -n "Are you sure $DEVICE is the correct device to format? (yes/no/exit): "
    	read confirm
        if [[ $confirm == "no" ]]; then
            echo -n "Select another device? (yes/exit): "
            read confirm
            if [[ $confirm == "yes" ]]; then
                bash $0
                exit $?
            else
                exit 0
            fi
        elif [[ $confirm == "exit" ]]; then
            echo "exiting..."
            exit 0
        fi
    done
else
    echo "DEVICE=\"$DEVICE\"" > "${path_here}/conf/block.tmp"
fi

echo "Preparing to format $DEVICE"
sleep 5
run "format-sdcard"
run "mount-partitions"
run "install-arch"
run "download-darchos-resources"

# Create a script to run Darchos setup script to prepare the environment on the first boot
# (it will remove itself after it ran successfully)
run "prepare-darchos"

## auto setup wifi if available in config.txt
[[ -n $WIFI_SSID && -n $WIFI_PASS ]] && run "setup-wifi"

run "add-configs"
echo "MicroSD is prepared for DArchOS to complete installation when it boots up"
run "unmount-partitions"
run "wrapup"

echo "Now connect the microSD to a Raspberry Pi 2/3 and apply the 5V power to finish the installation"