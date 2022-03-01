#!/bin/bash

# sudo sh video-output.sh
BWhite='\033[1;37m'; RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m' # color
if
[ $(id -u) -ne 0 ]; then echo "Please run as root"; exit 1; fi

if (systemctl -q is-active kodi.service); then
	echo ${BWhite}"stop kodi (10sec.)"${NC}
	systemctl stop kodi.service
	sleep 10
elif (systemctl -q is-active kodi.service); then
	echo ${BWhite}"stop kodi (+10sec.)"${NC}
	systemctl stop kodi.service
	sleep 10
exit 1
fi
echo

# HDMI to VGA adapter
echo -n ${BWhite}"Use HDMI to VGA adapter ? yes / no "${NC}
read answer
if [ "$answer" != "${answer#[Y|y]}" ]; then
	sed -i 's/#overscan_left=16/overscan_left=31/' /boot/config.txt
	sed -i 's/#hdmi_force_hotplug=1/hdmi_force_hotplug=1/' /boot/config.txt
	sed -i 's/#hdmi_group=1/hdmi_group=1/' /boot/config.txt
	sed -i 's/#hdmi_mode=1/hdmi_mode=6/' /boot/config.txt
	if grep -Fxq 'hdmi_drive=2' '/boot/config.txt'; then
		sed -i 's/hdmi_drive=2/#hdmi_drive=2/' /boot/config.txt
	elif grep -Fxq 'hdmi_drive=6' '/boot/config.txt'; then
		sed -i 's/#hdmi_mode=6/hdmi_mode=6/' /boot/config.txt
	fi

else
	sed -i 's/overscan_left=31/#overscan_left=16/' /boot/config.txt
	sed -i 's/hdmi_force_hotplug=1/#hdmi_force_hotplug=1/' /boot/config.txt
	sed -i 's/hdmi_group=1/#hdmi_group=1/' /boot/config.txt
	sed -i 's/hdmi_mode=6/#hdmi_mode=1/' /boot/config.txt
	sed -i 's/#hdmi_drive=2/hdmi_drive=2/' /boot/config.txt
	if grep -Fxq 'enable_tvout=0/' '/boot/config.txt'; then
		sed -i 's/enable_tvout=0/#enable_tvout=0/' /boot/config.txt
	fi
fi

