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

#echo ${BWhite}"KODI INTERFACE SETTINGS"${NC}
# Screen Calibrated
#if grep -Fxq 'hdmi_mode=6' '/boot/config.txt' ;then
#	if grep -Fxq '            <description>720x480 (720x480) @ 60.00i - Full Screen</description>' '/home/pi/.kodi/userdata/guisettings.xml' ;then
#		sed -i '
#/<resolutions \/>/a\
#<resolution>\
#<description>720x480 (720x480) @ 60.00i - Full Screen</description>\
#<subtitles>463</subtitles>\
#<pixelratio>0.888889</pixelratio>\
#<overscan>\
#	<left>24</left>\
#	<top>-2</top>\
#	<right>721</right>\
#	<bottom>475</bottom>\
#</overscan>\
#</resolution>\
#</resolutions>
#' /home/pi/.kodi/userdata/guisettings.xml
#		sed -i 's/<resolutions \/>/<resolutions>/' /home/pi/.kodi/userdata/guisettings.xml
#		echo ${GREEN}"Screen Calibrated"${NC}
#	fi
#else
#	echo ${GREEN}"You selected output Analog Video"${NC}
#fi

# Add sources /home/pi/movies/ & /home/pi/music/
if grep -Fxq '            <path pathversion="1">/home/pi/movies/</path>' '/home/pi/.kodi/userdata/sources.xml'; then
	echo
else
	cat <<'EOF' >> /home/pi/.kodi/userdata/sources.xml
<sources>
    <programs>
        <default pathversion="1"></default>
    </programs>
    <video>
        <default pathversion="1"></default>
        <source>
            <name>movies</name>
            <path pathversion="1">/home/pi/movies/</path>
            <allowsharing>true</allowsharing>
        </source>
    </video>
    <music>
        <default pathversion="1"></default>
        <source>
            <name>music</name>
            <path pathversion="1">/home/pi/music/</path>
            <allowsharing>true</allowsharing>
        </source>
    </music>
    <pictures>
        <default pathversion="1"></default>
    </pictures>
    <files>
        <default pathversion="1"></default>
    </files>
    <games>
        <default pathversion="1"></default>
    </games>
</sources>
EOF
fi
echo ${GREEN}"Add sources /home/pi/movies/ & /home/pi/music/"${NC}

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

# HiFiberry-dac
if grep -Fxq 'dtoverlay=hifiberry-dac' '/boot/config.txt' ;then
	#sed -i 's/id="audiooutput.audiodevice" default="true">PI:HDMI/id="audiooutput.audiodevice">ALSA:sysdefault:CARD=sndrpihifiberry/' /home/pi/.kodi/userdata/guisettings.xml
	sed -i 's/id="audiooutput.audiodevice" default="true">PI:HDMI/id="audiooutput.audiodevice">ALSA:pulse/' /home/pi/.kodi/userdata/guisettings.xml
	echo ${GREEN}"Audio output HiFiberry-dac"${NC}
elif grep -Fxq 'dtparam=audio=on' '/boot/config.txt' ;then
	if grep -Fxq 'defaults.pcm.card 0' '/etc/asound.conf' ;then
		sed -i 's/id="audiooutput.audiodevice" default="true">PI:HDMI/id="audiooutput.audiodevice">ALSA:pulse/' /home/pi/.kodi/userdata/guisettings.xml
		sed -i 's/id="audiooutput.audiodevice">ALSA:sysdefault:CARD=sndrpihifiberry/id="audiooutput.audiodevice">ALSA:pulse/' /home/pi/.kodi/userdata/guisettings.xml
		echo ${GREEN}"Audio output Analog 3,5mm"${NC}
	fi
else
	sed -i 's/id="audiooutput.audiodevice">ALSA:pulse/id="audiooutput.audiodevice" default="true">PI:HDMI/' /home/pi/.kodi/userdata/guisettings.xml
	echo ${GREEN}"Audio output HDMI"${NC}
fi
