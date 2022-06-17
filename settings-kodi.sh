#!/bin/bash

# sudo sh settings-kodi.sh
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

#Add sources /home/pi/video/
if grep -Fxq '            <path pathversion="1">/home/pi/movies/</path>' '/home/pi/.kodi/userdata/sources.xml'; then
	echo
else
	sed -i 's/<video>/<video>\
        <source>\
            <name>movies<\/name>\
            <path pathversion="1">\/home\/pi\/movies\/<\/path>\
            <allowsharing>true<\/allowsharing>\
        <\/source>/' /home/pi/.kodi/userdata/sources.xml
fi
echo ${GREEN}"Add sources /home/pi/movies/"${NC}

#Add sources /home/pi/music/
if grep -Fxq '            <path pathversion="1">/home/pi/music/</path>' '/home/pi/.kodi/userdata/sources.xml'; then
	echo
else
	sed -i 's/<music>/<music>\
        <source>\
            <name>music<\/name>\
            <path pathversion="1">\/home\/pi\/music\/<\/path>\
            <allowsharing>true<\/allowsharing>\
        <\/source>/' /home/pi/.kodi/userdata/sources.xml
fi
echo ${GREEN}"Add sources /home/pi/music/"${NC}

# Disable Screensaver
sed -i 's/id="screensaver.mode" default="true">screensaver.xbmc.builtin.dim/id="screensaver.mode">/' /home/pi/.kodi/userdata/guisettings.xml
echo ${GREEN}"Disable Screensaver"${NC}

# Enable auto play next video
sed -i 's/id="videoplayer.autoplaynextitem" default="true">/id="videoplayer.autoplaynextitem">0,1,2,3,4/' /home/pi/.kodi/userdata/guisettings.xml
echo ${GREEN}"Enable auto play next video"${NC}

# Amplifi volume up to 30.0dB
sed -i 's/volumeamplification>0.000000/volumeamplification>30.000000/' /home/pi/.kodi/userdata/guisettings.xml
echo ${GREEN}"Amplifi volume up to 30.0dB"${NC}

# Enable web-server
sed -i 's/id="services.webserver" default="true">false/id="services.webserver">true/' /home/pi/.kodi/userdata/guisettings.xml
echo ${GREEN}"Enable web-server"${NC}

# Video output
if grep -Fxq 'sdtv_mode=2' '/boot/config.txt'; then
	echo ${GREEN}"You selected output Video (Analog)"${NC}
fi
if grep -Fxq '# HDMI to VGA adapter for RNS' '/boot/config.txt'; then
	echo ${GREEN}"You selected output Video (HDMI to VGA)"${NC}
fi
# Audio output
if grep -Fxq 'dtoverlay=hifiberry-dac' '/boot/config.txt' ; then
	sed -i 's/id="audiooutput.audiodevice" default="true">PI:HDMI/id="audiooutput.audiodevice">ALSA:sysdefault:CARD=sndrpihifiberry/' /home/pi/.kodi/userdata/guisettings.xml
	sed -i 's/id="audiooutput.audiodevice" default="true">PI:Analogue/id="audiooutput.audiodevice">ALSA:sysdefault:CARD=sndrpihifiberry/' /home/pi/.kodi/userdata/guisettings.xml
	echo ${GREEN}"Audio output hifiberry-dac"${NC}
	if [ -e /etc/systemd/system/pulseaudio.service ]; then
		sed -i 's/id="audiooutput.audiodevice">ALSA:sysdefault:CARD=sndrpihifiberry/id="audiooutput.audiodevice">ALSA:pulse/' /home/pi/.kodi/userdata/guisettings.xml
		sed -i 's/id="audiooutput.audiodevice">PI:Analogue/id="audiooutput.audiodevice">ALSA:pulse/' /home/pi/.kodi/userdata/guisettings.xml
		sed -i 's/id="audiooutput.audiodevice">PI:HDMI/id="audiooutput.audiodevice">ALSA:pulse/' /home/pi/.kodi/userdata/guisettings.xml
		echo ${GREEN}"Audio output hifiberry-dac and Bluetoothe reciever (ALSA:pulse)"${NC}
	fi
elif grep -Fxq 'dtparam=audio=on' '/boot/config.txt'; then
	sed -i 's/id="audiooutput.audiodevice" default="true">PI:HDMI/id="audiooutput.audiodevice">PI:Analogue/' /home/pi/.kodi/userdata/guisettings.xml
	sed -i 's/id="audiooutput.audiodevice">ALSA:sysdefault:CARD=sndrpihifiberry/id="audiooutput.audiodevice">PI:Analogue/' /home/pi/.kodi/userdata/guisettings.xml
	sed -i 's/id="audiooutput.audiodevice">ALSA:pulse/id="audiooutput.audiodevice">PI:Analogue/' /home/pi/.kodi/userdata/guisettings.xml
	echo ${GREEN}"Audio output Analog Raspbrry PI 3,5mm"${NC}
	if [ -e /etc/systemd/system/pulseaudio.service ]; then
		sed -i 's/id="audiooutput.audiodevice">PI:Analogue/id="audiooutput.audiodevice">ALSA:pulse/' /home/pi/.kodi/userdata/guisettings.xml
		sed -i 's/id="audiooutput.audiodevice">PI:HDMI/id="audiooutput.audiodevice">ALSA:pulse/' /home/pi/.kodi/userdata/guisettings.xml
		sed -i 's/id="audiooutput.audiodevice">ALSA:sysdefault:CARD=sndrpihifiberry/id="audiooutput.audiodevice">ALSA:pulse/' /home/pi/.kodi/userdata/guisettings.xml
		echo ${GREEN}"Audio output Analog Raspbrry PI 3,5mm and Bluetoothe reciever (ALSA:pulse)"${NC}
	fi
else
	sed -i 's/id="audiooutput.audiodevice">ALSA:pulse/id="audiooutput.audiodevice" default="true">PI:HDMI/' /home/pi/.kodi/userdata/guisettings.xml
	sed -i 's/id="audiooutput.audiodevice">PI:Analogue/id="audiooutput.audiodevice" default="true">PI:HDMI/' /home/pi/.kodi/userdata/guisettings.xml
	sed -i 's/id="audiooutput.audiodevice">ALSA:sysdefault:CARD=sndrpihifiberry/id="audiooutput.audiodevice" default="true">PI:HDMI/' /home/pi/.kodi/userdata/guisettings.xml
	echo ${GREEN}"Audio output HDMI"${NC}
fi
