#!/bin/bash

### Sources 'get_parent_dir' and 'copy' functions, besides the ones imported from lib/message.sh

## messages
source lib/message.sh

## variables
source conf/conf.tmp


function get_parent_dir() {
    echo "${1%/*}"
}

function copy {
    if [[ -z $2 ]]; then
        init "Copying $1"
        mkdir --parents "$( get_parent_dir ${MOUNT_POINT:?}/root$1 )"
        cp --force "res$1" "${MOUNT_POINT:?}/root$1"
        end
    else
        init "Copying $1 to $2"
        mkdir --parents "$( get_parent_dir ${MOUNT_POINT:?}/root$2 )"
        if [[ -f "res$1" ]]; then
            cp --force "res$1" "${MOUNT_POINT:?}/root$2"
        elif [[ -f "$1" ]]; then
            cp --force "$1" "${MOUNT_POINT:?}/root$2"
        else
            end "failed to find $1 file"
        fi
        end
    fi
}
