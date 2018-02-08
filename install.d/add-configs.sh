#!/bin/bash

## messages
source lib/message.sh

## variables
source config.txt
source conf/conf.tmp


function add_config() {
    local default_value key max_value min_value value possible_values OPTIND
    possible_values=()
    while getopts ":d:k:v:p:P:m:M:" option; do
        case $option in
            d)
                default_value=$OPTARG >&2
                ;;
            k)
                key=$OPTARG >&2
                ;;
            m)
                min_value=$OPTARG >&2
                ;;
            M)
                max_value=$OPTARG >&2
                ;;
            p)
                possible_values+=("$OPTARG") >&2
                ;;
            P)
                for possible_value in $OPTARG; do
                    possible_values+=("$possible_value")
                done
                ;;
            v)
                value=$OPTARG >&2
                ;;
            \?)
                echo "invalid option -$OPTARG"
                exit 1
                ;;
        esac
    done
    if [[ -n $value ]]; then
        if [[ -n $max_value && $value -gt $max_value ]]; then
            echo "Maximum value for $key is ${max_value}, but the given value was $value"
            exit 1
        fi
        if [[ -n $min_value && $value -lt $min_value ]]; then
            echo "Mininum value for $key is ${min_value}, but the given value was $value"
            exit 1
        fi
        if [[ -n "${possible_values[*]}" && -z $( printf "%s\n" "${possible_values[@]}" | grep --line-regexp "$value" ) ]]; then
            echo "$value is not an allowed value for ${key}, the allowed ones are:"
            printf "%s, " "${possible_values[@]}"
            exit 1
        fi
        init "Adding value $value to $key (${key}=${value})"
        sed --in-place "/^${key}=/d" "${MOUNT_POINT:?}/boot/config.txt"
        echo "${key}=$value" >> "${MOUNT_POINT:?}/boot/config.txt"
        end
    elif [[ -n $default_value ]]; then
        init "Adding default value of $default_value to $key (${key}=${default_value})"
        sed --in-place "/^${key}=/d" "${MOUNT_POINT:?}/boot/config.txt"
        echo "${key}=$default_value" >> "${MOUNT_POINT:?}/boot/config.txt"
        end
    fi
}

# Raspberry Configuration text file
add_config -k disable_overscan -v "$DISABLE_OVERSCAN" -p 0 -p 1 -d 0
add_config -k disable_splash -v "$DISABLE_SPLASH" -d 0 -p 0 -p 1
add_config -k "dtparam=sd_overclock" -v "$SD_OVERCLOCK" -m 50 -d 50
add_config -k gpu_mem -v "$GPU_MEM" -m 16 -M 944 -d 64
add_config -k hdmi_cvt -v "$HDMI_CVT"
add_config -k hdmi_drive -v "$HDMI_DRIVE" -p 1 -p 2
add_config -k sdtv_aspect -v "$SDTV_ASPECT" -d 1 -P "$( seq 1 3 )"
add_config -k sdtv_mode -v "$SDTV_MODE" -d 0 -P "$( seq 0 3 )"

echo "All configurations added... Synchronizing now..."
sync