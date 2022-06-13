## Установка ПО для Audi Navigation Plus RNS-D и RNS-E (RNSPI)
![prototype scheme](https://github.com/maltsevvv/rnspi-install/blob/main/img/rnsd.png)
![prototype scheme](https://github.com/maltsevvv/rnspi-install/blob/main/img/rnse.png)


1. Записать на sd-карту с образом Raspbian Buster Lite
2. Cкопировать `skin.rnsd-main.zip` или `skin.rnse-main.zip` на sd-карту в /boot/

### install
`cd /tmp`  
`wget -q https://github.com/maltsevvv/rnspi-install/archive/main.zip`  
`unzip main.zip`  
`cd rnspi-install-main`  
`sudo sh install.sh`


#### Если используете USB Bluetoothe модуль, то его необходимо подключить вручную
`sudo bluetoothctl`  
`scan on`

находим свой телефон
`pair 5C:10:C5:E0:94:A6`  

Request PIN code  
[agent] Enter PIN code: `1234`  

`exit`



## Manual Install
#### edit /boot/config.txt  
`sudo nano /boot/config.txt`
```
# HDMI to VGA adapter for RNS
hdmi_force_hotplug=1
hdmi_ignore_edid=0xa5000080
hdmi_group=2
hdmi_mode=87
hdmi_timings 800 0 51 44 121 460 0 10 9 14 0 0 0 32 1 16000000 3
framebuffer_width=400
framebuffer_height=230

# Enable MCP2515 CanBus
dtparam=spi=on
dtoverlay=mcp2515-can0,oscillator=8000000,interrupt=25
dtoverlay=spi-bcm2835-overlay

# Enable audio (loads snd-hifiberry) and comment #dtparam=audio=on
dtoverlay=hifiberry-dac

# Enable video core & MPEG
gpu_mem=128
start_x=1
```

#### UPDATE
`sudo apt update`
#### DISABLE LOGGING
`sudo nano /etc/rsyslog.conf`
```
#module(load="imuxsock") # provides support for local system logging
#module(load="imklog") # provides kernel logging support
```
#### INSATALL KODI:
`sudo apt install kodi`  
`sudo nano /etc/systemd/system/kodi.service`
```
[Unit]
Description = Kodi Media Center
[Service]
User = pi
Group = pi
Type = simple
ExecStart = /usr/bin/kodi-standalone
Restart = always
RestartSec = 15
[Install]
WantedBy = multi-user.target
```
`sudo systemctl start kodi.service`  
`sudo systemctl enable kodi.service`


#### Создаем каталоги для хранения файлов
`sudo mkdir /home/pi/movies /home/pi/music /home/pi/mults`  
`sudo chmod -R 0777 /home/pi/movies /home/pi/music /home/pi/mults`


#### INSTALL can-utils python-setuptools python-pip libtool:
`sudo apt install python-pip`  
`sudo apt install can-utils`  
`sudo pip install python-can`  

### INSTALL SKIN.RNS-D IN KODI

#### Create service.tvtuner to emulate a TV tuner. If not installed in the car
`sudo nano /etc/systemd/system/tvtuner.service`
```
[Unit]
Description=Emulation tv-tuner 4BO919146B
[Service]
Type=simple
ExecStart=/usr/bin/python /home/pi/.kodi/addons/skin.rnsd/tvtuner.pyo
Restart=always
[Install]
WantedBy=multi-user.target
```
`sudo systemctl start tvtuner.service`  
`sudo systemctl enable tvtuner.service`  

#### INSTALL SAMBA:
`sudo apt install samba`  
`sudo nano /etc/samba/smb.conf`
```
[rns]
path = /home/pi/
create mask = 0775
directory mask = 0775
writeable = yes
browseable = yes
public = yes
force user = root
guest ok = yes
```
`sudo service smbd restart`  


# OVERLAY FS  
`sudo nano /usr/bin/raspi-config`  
После функции `do_overlayfs() {`  
Примерно в строках 2435 и 2479 RET=1 заменить на RET=0  
`sed -i '/do_overlayfs() {/,/}/ s/RET=$1/RET=0/' /usr/bin/raspi-config`  

Примерно в строке 2573 после  
`case $i in` добавить  
```
  --enable-overlayfs)
    INTERACTIVE=False
    do_overlayfs
    exit $?
    ;;
  --disable-overlayfs)
    INTERACTIVE=False
    disable_overlayfs
    exit $?
    ;;
```
```
sed -i '
/case $i in/a # ADD OVERLAY FS\
  --enable-overlayfs)\
    INTERACTIVE=False\
    do_overlayfs\
    exit $?\
    ;;\
  --disable-overlayfs)\
    INTERACTIVE=False\
    disable_overlayfs\
    exit $?\
    ;;\
' /usr/bin/raspi-config
```
#### Для запуска
`sudo raspi-config --enable-overlayfs`  
`sudo raspi-config --disable-overlayfs`
