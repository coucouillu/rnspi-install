#!/bin/bash

# sudo sh overlayfs.sh
BWhite='\033[1;37m'; RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m' # color
if
[ $(id -u) -ne 0 ]; then echo "Please run as root"; exit 1; fi

# OVERLAY FS SSH
echo ${BWhite}"Install overlay FS SSH"${NC}
if grep -Fxq '# ADD OVERLAY FS' '/usr/bin/raspi-config'
then
	sed -i '/do_overlayfs() {/,/}/ s/RET=$1/RET=0/' /usr/bin/raspi-config
	echo ${GREEN}"OK"${NC}
else
	sed -i '/do_overlayfs() {/,/}/ s/RET=$1/RET=0/' /usr/bin/raspi-config
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
	echo ${GREEN}"OK"${NC}
fi
echo
