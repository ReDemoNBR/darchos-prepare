#!/bin/bash

## functions
source lib/prompt.sh
source lib/recommendations.sh

## constants
source conf/config.conf

function set_password() {
    local user=$1
    while true; do
        prompt -st "Pick a password for $user" -v password
        prompt -st "Type it again" -v password_confirm
        if [[ "$password" == "$password_confirm" ]]; then
            eval "${user}_password=$password"
            break
        fi
        echo "Passwords did not match"
        sleep 1
    done
}

echo "Loading interactive mode..."
## capture all locales
locales=()
for locale in $( get_recommended_locales ); do
    [[ -n $locale && -z $( echo "${locales[@]}" | grep "$locale" ) ]] && locales+=("$locale")
done
while read line; do
    [[ -n $( echo $line | grep "^# " ) ]] && continue
    line=${line%% *}
    line=${line%%.*}
    line=${line###}
    [[ -n $line && -z $( echo "${locales[@]}" | grep "$line" ) ]] && locales+=("$line")
done < /etc/locale.gen

pick -nt "Install minimal (server - no graphical interface) version?" -o "yes" -o "no" -v server_version
if [[ "$server_version" == "yes" ]]; then
    server_version=1
else
    server_version=""
fi
prompt -t "Select a username" -d "$( get_recommended_username )" -v user_name
set_password user
set_password root
prompt -t  "Select a hostname" -d "${user_name}-darchos" -v hostname
pick -nt "Pick the main language" -O "${locales[*]}" -v language
## TODO: create a way to add multiple additional languages

## appends forcefully ARCH="armv7h" as there is no support for other archs
arch="armv7h"

pick -nt "Pick a keyboard layout" -D "/usr/share/kbd/keymaps/i386" -v keyboard_type
pick -nt "Pick a timezone" -D "/usr/share/zoneinfo" -v timezone
no_swap="No swapfile"
pick -nt "Pick a swapfile size (in bytes)" -o $no_swap -O "${SIZES_OPTIONS[*]}" -v swapfile_size
[[ "$swapfile_size" == "$no_swap" ]] && swapfile_size=
no_tmp_resize="No /tmp resize"
pick -nt "Pick a tmpfs size (mounted in /tmp)" -o $no_tmp_resize -O "${SIZES_OPTIONS[*]}" -v tmp_size
[[ "$tmp_size" == "$no_tmp_resize" ]] && tmp_size=
pick -nt "Will use wifi?" -o "yes" -o "no" -v wifi

if [[ "$wifi" == "yes" ]]; then
    prompt -t "SSID" -v wifi_ssid
    prompt -t "password" -v wifi_pass
else
    wifi_ssid=""
    wifi_pass=""
fi

#pick -t "Will use camera?" -o "yes" -o "no" -v camera
#if [[ "$camera" == "yes" ]]; then
#    gpu_mem=128
#else
#    gpu_mem=64
#fi
gpu_mem=64 ## forces 64M while there is no camera for testing

pick -nt "Will use audio through HDMI?" -o "yes" -o "no" -v hdmi_drive
if [[ "$hdmi_drive" == "yes" ]]; then
    hdmi_drive=1
else
    hdmi_drive=2
fi
pick -nt "Disable overscan?" -o "yes" -o "no" -v disable_overscan
if [[ "$disable_overscan" == "yes" ]]; then
    disable_overscan=1
else
    disable_overscan=0
fi

echo -e "\
USER_NAME=\"${user_name}\"\n\
USER_PASSWORD=\"${user_password}\"\n\
ROOT_PASSWORD=\"${root_password}\"\n\
HOSTNAME=\"${hostname}\"\n\
LANGUAGE=\"${language}\"\n\
ARCH=\"${arch}\"\n\
\n\
ADDITIONAL_LANGUAGES=($additional_languages)\n\
KEYBOARD_TYPE=\"${keyboard_type}\"\n\
TIMEZONE=\"${timezone}\"\n\
SWAPFILE_SIZE=\"${swapfile_size}\"\n\
TMP_SIZE=\"${tmp_size}\"\n\
SERVER_VERSION=\"${server_version}\"\n\
\n\
WIFI_SSID=\"${wifi_ssid}\"\n\
WIFI_PASS=\"${wifi_pass}\"\n\
\n\
GPU_MEM=${gpu_mem}\n\
HDMI_DRIVE=${hdmi_drive}\n\
DISABLE_OVERSCAN=${disable_overscan}\
" > $MAIN_CONFIG_FILE

echo "Config file generated successfully"