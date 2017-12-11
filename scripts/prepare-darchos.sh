#!/bin/bash

## functions (lib/copy.sh already sources lib/message.sh functions, but it will override them and this way it more readable)
source lib/message.sh
source lib/copy.sh

copy "/etc/locale.gen"
copy "/etc/pacman.conf"
copy "/etc/bash.bashrc"
copy "/etc/sudoers"
copy "/etc/motd"
copy "/etc/systemd/logind.conf"
copy "/etc/systemd/system/getty@tty1.service.d/override.conf"
copy "/usr/lib/os-release"
copy "/usr/lib/os-release" "/darchos/res/usr/lib/os-release"
copy "config.txt" "/darchos/config.txt"

sync

echo "Preparing done"