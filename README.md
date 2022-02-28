# Установка и настройка ПО для Audi Navigation Plus RNS-D и RNS-E (RNSPI)

1. Записать на sd-карту с образом Raspbian Buster Lite
2. Cкопировать `skin.rnsd.zip` или `skin.rnse.zip` на sd-карту в /boot/

### install

`cd /tmp`

`wget -q https://github.com/maltsevvv/rnspi-install/archive/main.zip`

`unzip main.zip`

`cd rnspi-install-main`

`sudo sh install.sh`

