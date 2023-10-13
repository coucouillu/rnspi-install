#!/bin/bash

# sudo sh video-output.sh
BWhite='\033[1;37m'; RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m' # color
if
[ $(id -u) -ne 0 ]; then echo "Please run as root"; exit 1; fi

if (systemctl -q is-active kodi.service); then
	echo ${BWhite}"Stop kodi (10sec.)"${NC}
	systemctl stop kodi.service
	sleep 10
elif (systemctl -q is-active kodi.service); then
	echo ${BWhite}"stop kodi (+10sec.)"${NC}
	systemctl stop kodi.service
	sleep 10
exit 1
fi
echo

# HDMI to VGA adapter for RNS
echo -n ${BWhite}"Use HDMI to VGA adapter ? yes / no "${NC}
read answer
if [ "$answer" != "${answer#[Y|y]}" ]; then
	if grep -Fxq 'sdtv_mode=2' '/boot/config.txt'; then
		sed -i 's/sdtv_mode=2/#sdtv_mode=2/' /boot/config.txt
	fi
	if grep -Fxq '# HDMI to VGA adapter for RNS' '/boot/config.txt'; then
		echo
	else
		cat <<'EOF' >> /boot/config.txt
# HDMI to VGA adapter for RNSE BY BRYCE
hdmi_ignore_edid=0xa5000080
hdmi_group=2
hdmi_mode=87
##### ##### hdmi_timings 800 0 51 44 121 460 0 10 9 14 0 0 0 32 1 16000000 3
hdmi_timings 800 0 40 44 150 548 0 15 9 16 0 0 0 32 1 17000000 1
framebuffer_width=400
##### ##### framebuffer_height=230
framebuffer_height=240
EOF
		sed -i 's/#disable_overscan=1/disable_overscan=1/' /boot/config.txt
		sed -i 's/#hdmi_force_hotplug=1/hdmi_force_hotplug=1/' /boot/config.txt
		echo -n ${BWhite}"Use Raspberry PI4 ?  yes / no "${NC}
		read answer
		if [ "$answer" != "${answer#[Y|y]}" ]; then
			if grep -Fxq 'enable_tvout=0' '/boot/config.txt'; then
				echo
			else
				cat <<'EOF' >> /boot/config.txt
enable_tvout=0
EOF
			fi
		fi
	fi
	
else
	if grep -Fxq '#sdtv_mode=2' '/boot/config.txt'; then
		sed -i 's/#sdtv_mode=2/sdtv_mode=2/' /boot/config.txt
	fi
	if grep -Fxq '# HDMI to VGA adapter for RNS' '/boot/config.txt'; then
		sed -i '/# HDMI to VGA adapter for RNS/d' /boot/config.txt
		sed -i '/hdmi_ignore_edid=0xa5000080/d' /boot/config.txt
		sed -i '/hdmi_group=2/d' /boot/config.txt
		sed -i '/hdmi_mode=87/d' /boot/config.txt
		sed -i '/hdmi_timings 800 0 51 44 121 460 0 10 9 14 0 0 0 32 1 16000000 3/d' /boot/config.txt
		sed -i '/framebuffer_width=400/d' /boot/config.txt
		sed -i '/framebuffer_height=230/d' /boot/config.txt
		sed -i '/enable_tvout=0/d' /boot/config.txt
		sed -i 's/disable_overscan=1/#disable_overscan=1/' /boot/config.txt
		sed -i 's/hdmi_force_hotplug=1/#hdmi_force_hotplug=1/' /boot/config.txt
	fi
fi
