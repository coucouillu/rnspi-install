#!/usr/bin/env python
from __future__ import print_function

import xbmc
import xbmcaddon
import xbmcgui
import xbmcplugin
import os
import sys
import binascii
import datetime
import subprocess
import re
import time
import string
import can
from minors import getlicense, getserialfile, getserial
from time import strftime, localtime, sleep, gmtime

os.system('sudo /sbin/ip link set can0 up type can bitrate 100000 restart-ms 100')
bus = can.Bus(interface='socketcan', channel='can0', receive_own_messages=True)

def dumpcan():
    up = 0
    down = 0
    left = 0
    right = 0
    back = 0
    setup = 0
    select = 0
    getlicense()
    if getserialfile() == getserial():
        for message in bus:
            canid = str(hex(message.arbitration_id).lstrip('0x').upper())
            msg = binascii.hexlify(message.data).decode('ascii').upper()
################ RNSE - PU
            if canid == '461': # RNSE
                xbmcgui.Window(10000).setProperty(canid, str(msg))
                if msg == '373001004001': #R.Encoder.Left
                    xbmc.executebuiltin('Action(Up)')
                elif msg == '373001002001': #R.Encoder.Right
                    xbmc.executebuiltin('Action(Down)')
                elif msg == '373001001000': #R.Encoder.Press
                    if select == 1:
                        xbmc.executebuiltin('Action(Select)')
                        select = 0
                    else:
                        select += 1
                elif msg == '373001000200': #RETURN
                    if back == 5:
                        xbmc.executebuiltin('Action(Back)')
                        back = 0
                    else:
                        back += 1                
                elif msg == '373001000100': #SETUP
                    if xbmc.getCondVisibility('VideoPlayer.IsFullscreen'):
                        if setup == 5:
                            xbmc.executebuiltin('Action(OSD)')
                            setup = 0
                        else:
                            setup += 1
                    else:
                        if setup == 5:
                            xbmc.executebuiltin('Action(ContextMenu)')
                            setup = 0
                        else:
                            setup += 1
                if msg == '373001400000': #UP
                    if xbmc.getCondVisibility('VideoPlayer.IsFullscreen'):
                        if up == 1:
                            xbmc.executebuiltin('PlayerControl(BigSkipForward)')
                            up = 0
                        else:
                            up += 1
                    else:
                        if up == 1:
                            xbmc.executebuiltin('Action(Up)')
                            up = 0
                        else:
                            up += 1
                elif msg == '373001800000': #DOWN
                    if xbmc.getCondVisibility('VideoPlayer.IsFullscreen'):
                        if down == 1:
                            xbmc.executebuiltin('PlayerControl(BigSkipBackward)')
                            down = 0
                        else:
                            down += 1
                    else:
                        if down == 1:
                            xbmc.executebuiltin('Action(Down)')
                            down = 0
                        else:
                            down += 1
                            
                elif msg == '373001010000': #PREVIOUS
                    # if xbmc.getCondVisibility('VideoPlayer.IsFullscreen'):
                        # if left == 1:
                            # xbmc.executebuiltin('PlayerControl(BigSkipBackward)')
                            # left = 0
                        # else:
                            # left += 1
                    if xbmc.getCondVisibility('Player.HasAudio'):
                        if left == 1:
                            xbmc.executebuiltin('XBMC.PlayerControl(Previous)')
                            left = 0
                        else:
                            left += 1
                    else:
                        if left == 1:
                            xbmc.executebuiltin('Action(Left)')
                            left = 0
                        else:
                            left += 1
                elif msg == '373001020000': #NEXT
                    if xbmc.getCondVisibility('VideoPlayer.IsFullscreen'):
                        if right == 5:
                            xbmc.executebuiltin('PlayerControl(BigSkipForward)')
                            right = 0
                        else:
                            right += 1
                    elif xbmc.getCondVisibility('Player.HasAudio'):
                        if right == 5:
                            xbmc.executebuiltin('XBMC.PlayerControl(Next)')
                            right = 0
                        else:
                            right += 1
                    else:
                        if rigth == 5:
                            xbmc.executebuiltin('Action(Right)')
                            right = 0
                        else:
                            right += 1
                elif msg == '377000000000': #TFT OFF
                    os.system('sudo reboot')
                # elif msg == '377001000000': #TFT ON
                    # os.system('sudo reboot')
    else:
        sleep(1)
        dumpcan()