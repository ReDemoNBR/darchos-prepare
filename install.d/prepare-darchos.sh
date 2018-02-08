#!/bin/bash

## functions (lib/copy.sh already sources lib/message.sh functions, but it will override them and this way it more readable)
source lib/message.sh
source lib/copy.sh
source config.txt


copy_res "/etc/locale.gen"
copy_res "/usr/lib/os-release"
copy_res "/etc/motd"
copy_res "/etc/pacman_${ARCH}.conf" "/etc/pacman.conf"

copy "/etc/bash.bashrc"
copy "/etc/sudoers"
copy "/etc/systemd/logind.conf"
copy "/etc/systemd/system/getty@tty1.service.d/override.conf"
copy "config.txt" "/darchos/config.txt"

sync

echo "Preparing done"