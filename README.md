# **DArchOS Prepare scripts**

## Table of Contents
* [Introduction](#introduction)
* [Features](#features)
* [Requirements](#requirements)
* [Purpose](#purpose)
* [How to use](#how-to-use)
    * [Generating configuration file](#generating-configuration-file)
    * [Preparing microSD](#preparing-microsd)
    * [Usage Examples](#usage-examples)
        * [Simple](#simple)
        * [Simple and Automated](#simple-and-automated)
        * [Fully Customized and Automated](#fully-customized-and-automated)
        * [Fully Interactive](#fully-interactive)
* [Customizable Values](#customizable-values)
    * [Required](#required)
    * [Optional](#optional)
    * [Wifi Connection](#wifi-connection)
    * [Raspberry Pi Boot Options](#raspberry-pi-boot-options)

---

## Introduction
DArchOS Prepare is a project that contains scripts to generate configuration files for
customizing [DArchOS][DArchOS] installation and to prepare the microSD card for
[Raspberry Pi 2/3][Raspberry Pi] single-board computers by formatting and downloading
initial resources to complete the installation

---

## Features
* Configuration generation with auto-detection, interactive and manual modes
* Preparation of microSD Card with DArchOS resources to be installed
    * MicroSD formatting with FAT16 (vfat) for /boot partition and EXT4 for / partition
    * ArchLinux-ARM installation
    * DArchOS resources downloading
    * Preparation for first-boot installation

---

## Requirements
* Raspberry Pi 2 or Raspberry Pi 3 single-board computer
* MicroSD with at least 16GB of storage (32GB or better recommended)
* MicroSD card reader/writer
* Stable network connection for downloading resources
    * For DArchOS installation, it is required a cabled internet or wifi with WPA/WPA2 security
* A working GNU/Linux-based system to format and prepare the MicroSD with DArchOS resources

---

## Purpose
DArchOS Prepare has the purpose to prepare and customize the installation of DArchOS Linux
distribution. It has been designed to be minimal and work on any ArchLinux-like distribution,
but without preventing users from other popular distributions from using it.

---

## How to use
### Generating configuration file
Can be done in 3 different ways with ```gen-config.sh``` script or manually:
1. **Interactive mode:**
    * Run ```bash gen-config.sh -I```
    * Follow the steps selecting username, password, timezone etc
2. **Auto-detection mode:**
    * Run ```bash gen-config.sh -S```
    * Standard password for user is ```darchos``` and ```darchosroot``` for root.
    * (Optional) add ```-q``` option to disable output to ```stdout```.
    Ex: ```bash gen-config.sh -Sq``` for less information in stdout
    * (Optional) add ```-s``` option to **enable ```SSH```** for remote login.
    Ex: ```bash gen-config.sh -Ss``` for **enabling** SSH
    * (Optional) add ```-ss``` option to **disable ```SSH```** and avoid remote login.
    Ex: ```bash gen-config.sh -Sss``` for **disabling** SSH
    * (Optional) add ```-t``` option to customize the ```/tmp``` tmpfs size.
    Ex: ```bash gen-config.sh -St 512M``` for mounting ```/tmp``` with ```512MB```
    * (Optional) add ```-u``` option to customize the username.
    Ex: ```bash gen-config.sh -Su foobar``` to create ```foobar``` user. If this option
    is not used, the default username is ```darchos```
    * (Optional) add ```-m``` option to install minimal/server version without graphical
    interface. Doesn't do anything at the moment but is being prepared to come in v0.3.x
    Ex: ```bash gen-config.sh -Sm``` for minimal version
    * (Optional) add ```-a``` option to customize the architecture to install. For now,
    only ```armv7h``` (for RPi2, RPi3) is supported but ```armv6h``` (for RPi0, RPi0w and
    RPi) is being prepared with v0.3.x
    Ex: ```bash gen-config.sh -Sa armv7h``` to generate config for Raspberry Pi 2 or
    Raspberry Pi 3 (3B+ not supported yet) single board computers.
    * (Optional) add ```-w``` option to connect to wifi with WPA/WPA2 security.
    Ex: ```bash gen-config.sh -Sw MyWifi:SekritPass ``` for connecting to
    wifi ```MyWifi``` with ```SekritPass``` WPA/WPA2 password
    * (Optional) add ```-z``` option to customize the swapfile size.
    Ex: ```bash gen-config.sh -Sz 1G``` for creating ```/swapfile``` with ```1GB```
3. **Manual mode:**
    * Create a copy of ```example-config.txt```
    * Save it as ```config.txt``` in the same directory
    * Edit ```config.txt``` to your preferences
    * Save it
    * Read [Customizable Values](#customizable-values) section for reference.

### Preparing microSD:
Can be done in with ```install.sh``` script. Always run as root (or using ```sudo```):
* Run ```bash install.sh```. It will prompt for which device to format.
It will format the device, download resources and prepare the microSD.
* (Optional) If you want to skip the device selection, add ```-d``` option and it will
ask for confirmation so you don't format the wrong device. Ex: ```bash install.sh -d /dev/sdb```
* (Optional) If you want to skip the device selection and the confirmation prompting (better
for automation), add ```-D``` option. Ex: ```bash install.sh -D /dev/sdb```
* (Optional) If you don't want the downloaded ArchLinux-ARM files to be removed after the microSD
preparation, add ```-n``` option. Ex: ```bash install.sh -n```
* (Optional) If you don't want any downloaded files to be removed after the microSD preparation,
add ```-nn``` option. Ex: ```bash install.sh -nn```
* (Optional) If you want to mount the partitions in a different path other than ```/mnt```,
add ```-m``` option passing an **absolute path**. Ex: ```bash install.sh -m /home/myuser/tmp```
* (Optional) If you want to change the path for the downloaded resources which defaults to ```/tmp```,
add ```-t``` option passing an **absolute path**. Ex: ```bash install.sh -t /home/myuser/tmp```
    * Should be good for developers/contributors when used in conjunction with ```-n```
    or ```-nn``` options, so it doesn't delete resources and you can test it again.
    Ex: ```bash install.sh -nnt /home/myuser/tmp```
* (Optional) If you want to download the WIP (work-in-progress) version of DArchOS resources,
add ```-w``` option. **This is not recommended for regular users.** Ex: ```bash install.sh -w```

### Usage Examples
#### Simple
Create user with ```darchos``` username and prepare the microSD that is assigned in ```/dev/sdc```
prompting for confirmation before formatting the device. User password will be ```darchos``` and
root password will be ```darchosroot```
```shell
## Create a config.txt file
bash gen-config.sh -S
## Prepare the microSD prompting for confirmation before formatting
sudo bash install.sh -d /dev/sdc
```
#### Simple and Automated
Create user ```foobar``` and prepare the microSD that is assigned in ```/dev/sdb``` without
prompting for confirmation before formatting the device. User password will be ```darchos```
and root password will be ```darchosroot```
```shell
## Create a config.txt file with user foobar (-u option)
bash gen-config.sh -Su foobar

## Prepare the microSD that is mounted in /dev/sdb without asking for confirmation
bash install.sh -D /dev/sdb
```
#### Fully Customized and Automated
Create user foobar and prepare the microSD that is assigned in ```/dev/sdd```, without prompting
for confirmation before formatting the device, autoconnecting to wifi that has SSID ```hello```
and password ```world``` adding custom mounting points and temporary path for the downloaded
resources, without deleting any of them. User password will be ```darchos``` and root password
will be ```darchosroot```
```shell
## Create a config.txt file with user_name foobar (-u option)
## with 1GB of swapfile (-s option)
## with 512MB for /tmp (-t option)
## auto-connecting to wifi with SSID 'MyWifi' that has 'SekritPass' password (-w option)
bash gen-config.sh -Su foobar -s 1G -t 512M -w MyWifi:SekritPass

## Prepare the microSD assigned in /dev/sdd without prompting for confirmation (-D option),
## mounting it in /tmp/darchos/mount (-m option)
## downloading the work-in-progress resources (-w option) to /tmp/darchos/download (-t option),
## without removing them after preparation (-nn option)
sudo bash install.sh -wnnD /dev/sdd -m /tmp/darchos/mount -t /tmp/darchos/download
```
#### Fully Interactive
Allows the user to customize the configuration by prompting inside the terminal
```shell
## Create a config.txt file by prompting the user (-I option).
## The -I option can be omitted as it is the default if -S option is not used
## Username, locale, passwords, timezone, swapfile size, /tmp size and more will be asked
bash gen-config.sh -I

## Prompts the user for which microSD to format
sudo bash install.sh
```

## Customizable Values
Some values can be customized by **editing manually** the ```config.txt``` file.
Read [Generating configuration file](#generating-configuration-file) for how to generate it.

### Required
These values are required, if any of them is not set correctly, might cause issues during
the installation process, ending up with a corrupted system.
* **USER_NAME:** name of the initial user of the system to be created. Set automatically
to ```darchos``` when ```gen-config.sh``` is ran with ```-S```. Can be customized
by ```-u``` option or in interactive mode (```-I``` option)
* **USER_PASSWORD:** password of the initial user. It is automatically set to ```darchos``` when
the ```gen-config.sh``` is ran with ```-S``` option, but can be set differently when ran
in interactive mode (```-I``` option)
* **ROOT_PASSWORD:** password of root user. It is automatically set to ```darchosroot``` when
the ```gen-config.sh``` is ran with ```-S``` option, but can be set differently when ran
in interactive mode (```-I``` option)
* **HOSTNAME:** hostname for the system. Automatically set to ```<USER_NAME>-darchos``` when
the ```gen-config.sh``` is ran with ```-S``` option (ex: if the **USER_NAME** is ```foobar```,
then it will be ```foobar-darchos```), but can be set differently when ran in interactive
mode (```-I``` option)
* **LANGUAGE:** main locale of the system. Automatically set to the same of the host system that is
generating the configuration file (uses ```en_US``` if none is detected) when ```gen-config.sh``` is
ran with ```-S```option. Can be set differently when ran in interactive mode (```-I``` option)
* **ARCH:** architecture of the system. Only ```armv7h``` is suppported for now. **Don't change it.**

### Optional
These values can be empty or unset. But it is recommended to have them correctly set for better
experience with DArchOS.
* **ADDITIONAL_LANGUAGES:** other locales to be used in the system. Automatically set to the same of
the host system that is generating the configuration file when ```gen-config.sh``` is ran
with ```-S``` option. Can **NOT** be set differently when ran in interactive mode (```-I``` option)
as it is not yet supported in this mode.
* **KEYBOARD_TYPE:** path for the keymap. Automatically set to the same of the host system that is
generating the configuration file when ```gen-config.sh``` is ran with ```-S``` option. **During the
interactive mode (```-I``` option), the options shown are from the actual host system.**
* **TIMEZONE:** timezone for the system. Automatically set to the same of the host system that is
generating the configuration file (uses UTC ```/usr/share/zoneinfo/Etc/UTC``` if none is detected)
when ```gen-config.sh``` is ran with ```-S``` option, but can be set differently when ran in
interactive mode (```-I``` option). **During the interactive mode (```-I``` option), the options
shown are from the actual host system.**
* **SWAPFILE_SIZE:** size (in bytes) for the swapfile that will be created in ```/swapfile```.
Automatically set to ```2G``` when ```gen-config.sh``` is ran with ```-S``` option. Can be customized
with ```-s``` option or when ran in interactive mode (```-I``` option).
**The swapfile will not be created if this value is empty**
* **TMP_SIZE:** size (in bytes) for the tmpfs (temporary filesystem) in ```/tmp```. Automatically set
to ```1G``` when ```gen-config.sh``` is ran with ```-S``` option. Can be customized with ```-t```
option or when ran in interactive mode (```-I``` option). **It will use half of the available RAM if
this value is empty**

### Wifi Connection
Autoconnect to wifi network. Wifi network must use WPA/WPA2 security or it will fail to connect to
internet, causing package installations to fail, so DArchOS installation will also fail, consequently.
**Do not add values to Wifi connection if you use a cabled connection**
* **WIFI_SSID:** SSID for the wifi network to be auto-connected when DArchOS installation starts. Can be
set with ```-w``` option when ```gen-config.sh``` is ran with ```-S``` option. Will be prompted
in interactive mode (```-I``` option)
* **WIFI_PASS:** WPA/WPA2 password for the wifi network to be auto-connected. Can be set with ```-w```
option when ```gen-config.sh``` is ran with ```-S``` option. Will be prompted in interactive
mode (```-I``` option)

### Raspberry Pi Boot Options
Use those with caution. _**Recommended to let them in peace, unless you really know what the heck you
are doing, or they might horse kick you in the face.**_
* **DISABLE_SPLASH:** disables rainbow splash screen on boot whether you set to ```1``` or to ```0```.
Always set to ```0``` by ```gen-config.sh```
* **GPU_MEM:** memory (in megabytes) that will be shared from RAM to GPU. If you plan to use camera, it
requires a at least ```128``` to work. It is automatically set to ```128``` by ```gen-config.sh```
for when camera will be used (```-c``` option, **UNTESTED**), or set to ```64``` otherwise
* **SD_OVERCLOCK:** overclock the microSD card reader of Raspberry Pi. It is unset by default
by ```gen-config.sh``` which inherits the default value of ```50``` in Raspberry Pi board. **With a
value of 100 (or higher) most microSDs (even some UHS-3) dont even boot up**
* **DISABLE_OVERSCAN:** disables the overscan (black edges on the video) where you set it to ```1```
or to ```0```, which is a common for very old CRT monitors. Modern monitors with digital signals
(DVI, HDMI, DisplayPort) don't suffer this problem. Automatically set to ```1``` when ```gen-config.sh```
is ran with ```-S``` option, but can be set differently when in interactive mode (```-I``` option)
* **HDMI_DRIVE:** allows to pass audio through HDMI video output when set to ```1```, or doesn't when
set to ```2```. Automatically set to ```1``` when ```gen-config.sh``` is ran with ```-S``` option,
but can be set differently when in interactive mode (```-I``` option)
* **HDMI_CVT:** allows forcing a very specific resolution to Raspberry Pi. It is unset by default
by ```gen-config.sh```, which allows Raspberry Pi board to automatically detect the best option.
Read [Raspberry Pi config.txt docs — Custom mode][RPi Config]
* **SDTV_MODE:** standard TV output mode selection. It is unset by default by ```gen-config.sh```, which
allows Raspberry Pi board to automatically detect the best option. There are 4 possible values:
    * ```0``` for NTSC
    * ```1``` for Japanese NTSC
    * ```2``` for PAL
    * ```3``` for Brazilian PAL
* **SDTV_ASPECT:** video aspect ratio. It is unset by default by ```gen-config.sh```, which allows
Raspberry Pi board to automatically detect the best option. Setting any value here is almost useless
Because the operating system, video driver and display server will take care of everything after boot.
Anyway, there are 3 possible values:
    * ```1``` for 4:3
    * ```2``` for 14:9
    * ```3``` for 16:9


[Raspberry Pi]: https://www.raspberrypi.org "Raspberry Pi (Official Site)"
[RPi Config]: https://www.raspberrypi.org/documentation/configuration/config-txt/video.md "Raspberry Pi Config.txt (Docs)"
[DArchOS]: https://github.com/ReDemoNBR/darchos/ "DArchOS (on GitHub)"
