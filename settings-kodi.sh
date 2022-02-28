#!/bin/bash

BWhite='\033[1;37m'; RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m' # color
if
[ $(id -u) -ne 0 ]; then echo "Please run as root"; exit 1; fi
echo

systemctl stop kodi.service
sleep 5
		
echo ${BWhite}"stop kodi.service"${NC}
if (systemctl -q is-active kodi.service); then
	systemctl stop kodi.service
	sleep 10
elif (systemctl -q is-active kodi.service); then
	systemctl stop kodi.service
	sleep 10
exit 1
fi
echo

echo ${BWhite}"Screen Calibrated"${NC}
if grep -Fxq 'hdmi_mode=6' '/boot/config.txt' ;then
	if grep -Fxq '            <description>720x480 (720x480) @ 60.00i - Full Screen</description>' '/home/pi/.kodi/userdata/guisettings.xml' ;then
		sed -i '
/<resolutions \/>/a\
<resolution>\
<description>720x480 (720x480) @ 60.00i - Full Screen</description>\
<subtitles>463</subtitles>\
<pixelratio>0.888889</pixelratio>\
<overscan>\
	<left>24</left>\
	<top>-2</top>\
	<right>721</right>\
	<bottom>475</bottom>\
</overscan>\
</resolution>\
</resolutions>
' /home/pi/.kodi/userdata/guisettings.xml
		sed -i 's/<resolutions \/>/<resolutions>/' /home/pi/.kodi/userdata/guisettings.xml
		echo ${GREEN}"OK"${NC}
	fi
else
	echo ${GREEN}"You selected output Analog Video"${NC}
fi
echo

## Disable Screensaver
echo ${BWhite}"Disable Screensaver"${NC}
sed -i 's/id="screensaver.mode" default="true">screensaver.xbmc.builtin.dim/id="screensaver.mode">/' /home/pi/.kodi/userdata/guisettings.xml
echo ${GREEN}"OK"${NC}
echo

## Enable auto play next video
echo ${BWhite}"Enable auto play next video"${NC}
sed -i 's/id="videoplayer.autoplaynextitem" default="true">/id="videoplayer.autoplaynextitem">0,1,2,3,4/' /home/pi/.kodi/userdata/guisettings.xml
echo ${GREEN}"OK"${NC}
echo

## volume UP +30.0dB
echo ${BWhite}"Amplifi volume up to 30.0dB"${NC}
sed -i 's/volumeamplification>0.000000/volumeamplification>30.000000/' /home/pi/.kodi/userdata/guisettings.xml
echo ${GREEN}"OK"${NC}
echo

## Enable web-server
echo ${BWhite}"Enable web-server"${NC}
sed -i 's/id="services.webserver" default="true">false/id="services.webserver">true/' /home/pi/.kodi/userdata/guisettings.xml
echo ${GREEN}"OK"${NC}
echo

echo ${BWhite}"HiFiberry-dac"${NC}
if grep -Fxq 'dtoverlay=hifiberry-dac' '/boot/config.txt' ;then
	sed -i 's/id="audiooutput.audiodevice" default="true">PI:HDMI/id="audiooutput.audiodevice">ALSA:sysdefault:CARD=sndrpihifiberry/' /home/pi/.kodi/userdata/guisettings.xml
	echo ${BWhite}"Audio output HiFiberry-dac"${NC}

else
	sed -i 's/id="audiooutput.audiodevice" default="true">PI:HDMI/id="audiooutput.audiodevice">ALSA:pulse/' /home/pi/.kodi/userdata/guisettings.xml
	sed -i 's/id="audiooutput.audiodevice">ALSA:sysdefault:CARD=sndrpihifiberry/id="audiooutput.audiodevice">ALSA:pulse/' /home/pi/.kodi/userdata/guisettings.xml
	echo ${BWhite}"Audio output Analog 3,5mm"${NC}
fi
