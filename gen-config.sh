#!/bin/bash

source conf/config.conf

function help() {
    echo -e "Usage:\n\
\tbash gen-config.sh -S [-a ARCH] [-cmqs] [-t SIZE] [-u USERNAME] [-w SSID:PASS] [-z SIZE] \n\
\tbash gen-config.sh [-I]\n\
\n\
MAIN OPTIONS:\n\
  -h\t\t\tShow this help text\n\
  -I\t\t\tGenerate config file interactively
  -S\t\t\tUse recommended settings and this environment configuration, like keyboard layout (keymap), timezone and locales, to generate config file\n\
\n\
EXCLUSIVE OPTIONS FOR -S:\n\
  -a ARCH\t\tSet architecture to ARCH. Options supported ${SUPPORTED_ARCHS[*]}\n\
  -f\t\t\tAdd user to 'wheel' group so it can use 'sudo' commands. Use -ff to disable sudo for user
  -m\t\t\tInstall minimal (server - no graphical interface) version\n\
  -q\t\t\tQuiet. Don't print anything to stdout\n\
  -s\t\t\tEnable SSH (default) for after the installation. Use -ss to disable SSH\n\
  -t SIZE\t\tResize /tmp tmpfs to SIZE size (set 0 for no resize). Read VALID SIZE for reference (default=1G)\n\
  -u USERNAME\t\tSet the USERNAME to be the name of the user to be created (default='darchos')\n\
  -w SSID:PASS\t\tAutoconnect DArchOS to Wifi with given SSID and PASS using WPA/WPA2 security. Don't use this option for cabled connection\n\
  -z SIZE\t\tCreate a swapfile in /swapfile with SIZE size (set 0 for no creation). Read VALID SIZES for references (default=2G)\n\
\n\
VALID SIZES:\n\
  Use K for kilobytes, M for megabytes and G for gigabytes.\n\
  Ex: 512K for 512 kilobytes, 128M for 128 megabytes and 2G for 2 gigabytes"
}

[[ -n $( echo "$@" | grep --perl-regexp "(^|\s)--help($|\s)" ) ]] && help

function exit_error() {
    echo "$*"
    exit 1
}

## Change to "this" directory (the root of darchos-script)
cd "$( dirname "$( pwd -P )/$0" )"
path_here=$(pwd)

function run() {
    local status
    cd "$path_here"
    bash "${path_here}/gen-config.d/${1}.sh"
    status=$?
    [[ -n $( find ${path_here}/conf -name '*.tmp' ) ]] && rm --force ${path_here}/conf/*.tmp
    exit $status
}

while getopts ":hISa:fmqst:u:w:z:" option; do
    case $option in
        h)
            help
            ;;
        I)
            interactive=1
            ;;
        S)
            recommended_settings=1
            ;;
        a)
            [[ -z $( echo "${SUPPORTED_ARCHS[*]}" | grep --word-regexp "$OPTARG" ) ]] && exit_error "Invalid arch -$OPTARG"
            arch="$OPTARG"
            ;;
        f)
            [[ $sudo -eq 1 ]] && sudo=$((!sudo))
            [[ -z $sudo ]] && sudo=1
            ;;
        m)
            server_version=1
            ;;
        q)
            quiet=1
            ;;
        s)
            [[ $ssh -eq 1 ]] && ssh=$((!ssh))
            [[ -z $ssh ]] && ssh=1
            ;;
        t)
            tmp_size="$OPTARG"
            ;;
        u)
            user="$OPTARG"
            ;;
        w)
            wifi_ssid=${OPTARG%%:*}
            wifi_pass=${OPTARG##*:}
            ;;
        z)
            swapfile_size="$OPTARG"
            ;;
        :)
            echo "Missing argument in -$OPTARG"
            exit 1
            ;;
        ?)
            echo "Invalid option -$OPTARG"
            exit 1
            ;;
    esac
done
[[ -n $interactive && -n $recommended_settings ]] && exit_error "Can not use -I and -S options at the same time"

if [[ -n $recommended_settings ]]; then
    echo -e "\
USER_NAME=\"${user:-"darchos"}\"\n\
CAMERA=${camera:-0}\n\
SERVER_VERSION=${server_version}\n\
ARCH=\"${arch:-"armv7h"}\"\n\
QUIET=${quiet:-0}\n\
SSH=${ssh:-1}\n\
SUDO=${sudo:-1}\n\
SWAPFILE_SIZE=\"${swapfile_size}\"\n\
TMP_SIZE=\"${tmp_size}\"\n\
WIFI_SSID=\"${wifi_ssid}\"\n\
WIFI_PASS=\"${wifi_pass}\"" > $GEN_CONFIG_SETTINGS
    run "recommended-settings"
else
    run "interactive"
fi