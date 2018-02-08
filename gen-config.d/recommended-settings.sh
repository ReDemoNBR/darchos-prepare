#!/bin/bash

## functions
source lib/recommendations.sh

## variables
source conf/config.conf
[[ -f $GEN_CONFIG_SETTINGS ]] && source $GEN_CONFIG_SETTINGS

[[ -f $STD_CONFIG_TMP_FILE ]] && rm $STD_CONFIG_TMP_FILE

# get recommended settings by detecting configurations in actual host machine
## username
username="$USER_NAME"
## main locale
language=$( grep ^LANG= /etc/locale.conf | cut --delimiter '=' --fields 2 )
[[ -z $language ]] && language=$( grep ^LANGUAGE= /etc/locale.conf | cut --delimiter '=' --fields 2 )
language=${language%%.*}
language=${language:-"en_US"}
all_languages=$( get_recommended_locales )
## additional languages
additional_languages=()
for lang in $all_languages; do
    [[ "$language" != "$lang" ]] && additional_languages+=("$lang")
done
## timezone
timezone=$( get_recommended_timezone )
## keymap (keyboard layout)
keymap=$( get_recommended_keymap )

gpu_mem=$( get_recommended_gpumem $SERVER_VERSION )

# Forced values
swapfile=${SWAPFILE_SIZE:-$(get_recommended_swapfile)}
[[ "$swapfile" == "0" ]] && swapfile=""
tmp_size=${TMP_SIZE:-$(get_recommended_tmpsize)}
[[ "$tmp_size" == "0" ]] && tmp_size=""
wifi_ssid="$WIFI_SSID"
wifi_pass="$WIFI_PASS"
ssh="$SSH"
sudo="$SUDO"
disable_splash=0
disable_overscan=0
sd_overclock=""
hdmi_drive=1
hdmi_cvt=""
sdtv_mode=""
sdtv_aspect=""


echo -e "\
USER_NAME=\"${username}\"\n\
USER_PASSWORD=\"${STD_USER_PASSWORD}\"\n\
ROOT_PASSWORD=\"${STD_ROOT_PASSWORD}\"\n\
HOSTNAME=\"${username}-darchos\"\n\
LANGUAGE=\"${language}\"\n\
ARCH=\"${ARCH}\"\n\
SERVER_VERSION=\"${SERVER_VERSION}\"\n\
\n\
ADDITIONAL_LANGUAGES=(${additional_languages[*]})\n\
KEYBOARD_TYPE=\"${keymap}\"\n\
TIMEZONE=\"${timezone}\"\n\
SWAPFILE_SIZE=\"${swapfile}\"\n\
TMP_SIZE=\"${tmp_size}\"\n\
\n\
WIFI_SSID=\"${wifi_ssid}\"\n\
WIFI_PASS=\"${wifi_pass}\"\n\
\n\
SSH=${ssh}\n\
SUDO=${sudo}\n\
\n\
DISABLE_SPLASH=${disable_splash}\n\
GPU_MEM=${gpu_mem}\n\
DISABLE_OVERSCAN=${disable_overscan}\n\
SD_OVERCLOCK=${sd_overclock}\n\
HDMI_DRIVE=${hdmi_drive}\n\
HDMI_CVT=\"${hdmi_cvt}\"\n\
SDTV_MODE=\"${sdtv_mode}\"\n\
SDTV_ASPECT=\"${sdtv_aspect}\"\n" > $STD_CONFIG_TMP_FILE

[[ $QUIET -ne 1 ]] && cat $STD_CONFIG_TMP_FILE
cp --force "$STD_CONFIG_TMP_FILE" "config.txt"