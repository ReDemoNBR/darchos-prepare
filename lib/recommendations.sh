#!/bin/bash

function get_recommended_username() {
    local username
    username=$( whoami )
    [[ $username == "root" ]] && username="darchos"
    echo $username
}

function get_recommended_locales() {
    local all_locales=() locale_conf locale_gen locale_ctl locale
    locale_conf=$( cut --delimiter '=' --fields 2 /etc/locale.conf | cut --delimiter '.' --fields 1 )
    locale_gen=$( grep "^[^#;]" /etc/locale.gen | cut --delimiter ' ' --fields 1 | cut --delimiter '.' --fields 1 )
    locale_ctl=$( localectl list-locales | grep --fixed-string --invert-match '.' )
    for locale in $locale_conf $locale_gen $locale_ctl; do
        [[ -z $( echo "${all_locales[*]}" | grep --word-regexp $locale ) ]] && all_locales+=("$locale")
    done
    echo "${all_locales[@]}"
}

function get_recommended_timezone() {
    if [[ -L /etc/localtime ]]; then
        readlink --canonicalize /etc/localtime
    else
        echo "/usr/share/zoneinfo/Etc/UTC"
    fi
}

function get_recommended_keymap() {
    local vconsole_keymap
    vconsole_keymap=$( grep ^KEYMAP= /etc/vconsole.conf | cut --delimiter '=' --fields 2 )
    echo "$( find /usr/share/kbd/keymaps/i386 -name ${vconsole_keymap}.map.gz )"
}

function get_recommended_swapfile() {
    echo "2G"
}

function get_recommended_tmpsize() {
    echo "1G"
}

function get_recommended_gpumem() {
    ## 16MB for server as video usage is not required
    ## 64MB otherwise
    if [[ $1 -eq 1 ]]; then
        echo 16
    else
        echo 64
    fi
}