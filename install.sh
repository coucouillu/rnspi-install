#!/bin/bash

BWhite='\033[1;37m'; BBlue='\033[1;34m'; RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m' # color
if
[ $(id -u) -ne 0 ]; then echo "Please run as root"; exit 1; fi

echo ${BWhite}"Check OS version in Raspbian"${NC}
if grep -Fxq 'VERSION="10 (buster)"' '/etc/os-release'; then echo ${GREEN}"You using Raspbian Buster"${NC}; else echo ${RED}"You are not using Raspbian Buster"${NC}; exit 0; fi
echo
####

echo ${BWhite}"Сhecking the internet connection"${NC}
echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1
[ $? -eq 0 ]
if [ $? -eq 0 ]; then echo ${GREEN}"OK"${NC}; else echo ${RED}"NOT internet connection"${NC}; exit 0; fi
echo
####

echo ${BWhite}"Check file on SD card in /boot/ skin.rnsd.zip or skin.rnse.zip"${NC}
if [ -e /boot/skin.rnsd-main.zip ]; then echo ${GREEN}"OK"${NC}; elif [ -e /boot/skin.rnse-main.zip ]; then echo ${GREEN}"OK"${NC}; else echo ${RED}"SKIN not found"${NC}; exit 0; fi
echo
####

echo ${BWhite}"update system"${NC}
apt update -y
apt upgrade -y
echo
####

echo ${BWhite}"install kodi"${NC}
apt install kodi -y
cat <<'EOF' > /etc/systemd/system/kodi.service
[Unit]
Description=Kodi Media Center
[Service]
User=pi
Group=pi
Type=simple
ExecStart=/usr/bin/kodi-standalone
Restart=always
RestartSec=15
[Install]
WantedBy=multi-user.target
EOF
systemctl enable kodi.service
systemctl start kodi.service
echo ${GREEN}"OK"${NC}
echo
# disable service.xbmc.versioncheck #
sed -i '/service.xbmc.versioncheck/d' /usr/share/kodi/system/addon-manifest.xml
echo ${GREEN}"Disable service.xbmc.versioncheck"${NC}
echo
#
echo ${BWhite}"install can-utils"${NC}
apt install -y can-utils
echo ${GREEN}"OK"${NC}
echo
#
echo ${BWhite}"install python-pip"${NC}
apt install -y python-pip
echo ${GREEN}"OK"${NC}
echo
#
echo ${BWhite}"Install python-can"${NC}
pip install python-can
echo ${GREEN}"OK"${NC}
echo
#
# echo ${BWhite}"install usbmount"${NC}
# apt install -y usbmount
# sed -i 's/PrivateMounts=yes/PrivateMounts=no/' /lib/systemd/system/systemd-udevd.service
# sed -i 's/FS_MOUNTOPTIONS=""/FS_MOUNTOPTIONS="-fstype=vfat,iocharset=utf8,gid=root,dmask=0002,fmask=0002"/' /etc/usbmount/usbmount.conf
echo ${BWhite}"install automount usb"${NC}
cd udev-media-automount
sudo make install
echo ${GREEN}"OK"${NC}
echo
#
echo ${BWhite}"install samba"${NC}
echo "samba-common samba-common/workgroup string  WORKGROUP" | sudo debconf-set-selections
echo "samba-common samba-common/dhcp boolean true" | sudo debconf-set-selections
echo "samba-common samba-common/do_debconf boolean true" | sudo debconf-set-selections
apt install -y samba
# samba config
if grep -Fxq 'path = /home/pi/' '/etc/samba/smb.conf'
then
	echo ${GREEN}"OK"${NC}
else
	cat <<'EOF' >> /etc/samba/smb.conf
[rns]
path = /home/pi/
create mask = 0775
directory mask = 0775
writeable = yes
browseable = yes
public = yes
force user = root
guest ok = yes
EOF
	service smbd restart
	echo ${GREEN}"OK"${NC}
fi
echo


#### EDIT /BOOT/CONFIG.TXT
echo ${BWhite}"EDIT /BOOT/CONFIG.TXT"${NC}
# Enable MCP2515 CanBus
if grep -Fxq 'dtoverlay=mcp2515-can0,oscillator=8000000,interrupt=25' '/boot/config.txt'; then
	echo ${GREEN}"Enable MCP2515 CanBus"${NC}
else
	cat <<'EOF' >> /boot/config.txt

# Enable MCP2515 CanBus
dtparam=spi=on
dtoverlay=mcp2515-can0,oscillator=8000000,interrupt=25
dtoverlay=spi-bcm2835-overlay
EOF
	echo ${GREEN}"Enable MCP2515 CanBus"${NC}
fi

# GPU 128MB
if grep -Fxq 'gpu_mem=128' '/boot/config.txt'; then
	echo ${GREEN}"GPU 128MB"${NC}
else
	cat <<'EOF' >> /boot/config.txt

gpu_mem=128
EOF
	echo ${GREEN}"GPU 128MB"${NC}
fi

# Enable MPEG codec
if grep -Fxq 'start_x=1' '/boot/config.txt'; then
	echo ${GREEN}"Enable MPEG codec"${NC}
else
	cat <<'EOF' >> /boot/config.txt

start_x=1
EOF
	echo ${GREEN}"Enable MPEG codec"${NC}
fi
echo

echo ${BBlue}"Installing components"${NC}
sh install-bluetoothe.sh
sh video-output.sh
sh install-skin.sh
sh enable-hifiberry.sh
sh settings-kodi.sh
echo

echo -n ${BWhite}"Reboot System Now ? yes / no "${NC}
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
	reboot
fi
