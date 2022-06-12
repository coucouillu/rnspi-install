#!/bin/bash

# sudo sh update.sh
BWhite='\033[1;37m'; RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m' # color
if
[ $(id -u) -ne 0 ]; then echo "Please run as root"; exit 1; fi


echo ${BWhite}"Check file on SD card in /home/pi/ skin.rnsd.zip or skin.rnse.zip"${NC}
if [ -e /home/pi/skin.rnsd-main.zip ]; then echo ${GREEN}"OK"${NC}; elif [ -e /home/pi/skin.rnse-main.zip ]; then echo ${GREEN}"OK"${NC}; else echo ${RED}"SKIN not found"${NC}; exit 0; fi
echo
	if (systemctl -q is-active kodi.service); then
		echo ${BWhite}"stop kodi (10sec.)"${NC}
		systemctl stop kodi.service
		sleep 10
	elif (systemctl -q is-active kodi.service); then
		systemctl stop kodi.service
		sleep 10
	fi

	# chek tvtuner.service
	if (systemctl -q is-active tvtuner.service); then
		echo ${BWhite}"stop tvtuner (5sec.)"${NC}
		systemctl stop tvtuner.service
		sleep 5
	elif (systemctl -q is-active tvtuner.service); then
		systemctl stop tvtuner.service
		sleep 5
	fi

	# проверить файл
	echo ${BWhite}"Check file on SD card in /home/pi/ skin.rnsd.zip or skin.rnse.zip"${NC}
	if [ -e /home/pi/skin.rnsd.zip ]; then
		echo ${GREEN}"found skin.rnsd"${NC}
		unzip ~/skin.rnsd-main.zip -d /tmp/
		mv /tmp/skin.rnsd-main /tmp/skin.rnsd
		rm -r /home/pi/.kodi/addons/skin.rnsd
		cp /tmp/skin.rnsd -r /home/pi/kodi/addons/
		
		
	elif [ -e /home/pi/skin.rnse.zip ]; then
		echo ${GREEN}"found skin.rnse"${NC}
		unzip ~/skin.rnse-main.zip -d /tmp/
		mv /tmp/skin.rnse-main /tmp/skin.rnse
		rm -r /home/pi/.kodi/addons/skin.rnse
		cp /tmp/skin.rnse -r /home/pi/kodi/addons/
	fi	
	
	if (systemctl -q is-enabled tvtuner.service); then
		systemctl start tvtuner.service
	fi
	systemctl start kodi.service
