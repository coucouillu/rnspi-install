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
################ RNSE
            if canid == '661': # rnse tv-tuner
                os.system('cansend can0 602#8912300000000000 &')
            elif canid == '461': # RNSE
                xbmcgui.Window(10000).setProperty(canid, str(msg))
                if msg == '373001400000': #LEFT_UP - up
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
                elif msg == '373001800000': #LEFT_DOWN - down
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
                            
                elif msg == '373001010000' or msg == '373004000100': #PREVIOUS - left
                    if xbmc.getCondVisibility('VideoPlayer.IsFullscreen'):
                        if left == 1:
                            xbmc.executebuiltin('PlayerControl(BigSkipBackward)')
                            left = 0
                        else:
                            left += 1
                    elif xbmc.getCondVisibility('Player.HasAudio'):
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
                elif msg == '373004004000': #NEXT - right
                    if xbmc.getCondVisibility('VideoPlayer.IsFullscreen'):
                        if right == 1:
                            xbmc.executebuiltin('PlayerControl(BigSkipForward)')
                            right = 0
                        else:
                            right += 1
                    elif xbmc.getCondVisibility('Player.HasAudio'):
                        if right == 1:
                            xbmc.executebuiltin('XBMC.PlayerControl(Next)')
                            right = 0
                        else:
                            right += 1
                    else:
                        if right == 1:
                            xbmc.executebuiltin('Action(Right)')
                            right = 0
                        else:
                            right += 1
                elif msg == '373001000200': #RETURN
                    if back == 1:
                        xbmc.executebuiltin('Action(Back)')
                        back = 0
                    else:
                        back += 1
                elif msg == '373001000100': #SETUP
                    if xbmc.getCondVisibility('VideoPlayer.IsFullscreen'):
                        if setup == 1:
                            xbmc.executebuiltin('Action(OSD)')
                            setup = 0
                        else:
                            setup += 1
                    else:
                        if setup == 1:
                            xbmc.executebuiltin('Action(ContextMenu)')
                            setup = 0
                        else:
                            setup += 1
                elif msg== '373001001000': #R.Encoder.Press
                    if select == 1:
                        xbmc.executebuiltin('Action(Select)')
                        select = 0
                    else:
                        select += 1
                elif msg == '373004002000' or msg == '373001002001': #R.Encoder.Right
                    if down == 5:
                        xbmc.executebuiltin('Action(Down)')
                        down = 0
                    else:
                        down += 1
                elif msg == '373004004000' or msg == '373001004001': #R.Encoder.Left
                    if up == 5:
                        xbmc.executebuiltin('Action(Up)')
                        up = 0
                    else:
                        up += 1
################ POWER OFF               
            # #elif canid == '271' and msg[0:2] == '10' or msg[0:2] == '00':
            # elif canid == '271' and msg == '11':
				# #os.system('sudo halt')
                # os.system('sudo reboot')
################ MFSW 5C0
            elif canid == '5C0':
                xbmcgui.Window(10000).setProperty(canid, str(msg))
                if msg == '3902': #MFSW Left #RETURN
                    xbmc.executebuiltin('Action(Back)')
                elif msg == '3903': #MFSW Right #SELECT
                    xbmc.executebuiltin('Action(Select)')
                elif msg == '3904': #MFSW Up #UP
                    if xbmc.getCondVisibility('VideoPlayer.IsFullscreen'):
                        xbmc.executebuiltin('PlayerControl(BigSkipForward)')
                    elif xbmc.getCondVisibility('Player.HasAudio'):
                        xbmc.executebuiltin('XBMC.PlayerControl(Next)')
                    else:
                        xbmc.executebuiltin('Action(Up)')
                elif msg == '3905': #MFSW Down #DOWN
                    if xbmc.getCondVisibility('VideoPlayer.IsFullscreen'):
                        xbmc.executebuiltin('PlayerControl(BigSkipBackward)')
                    elif xbmc.getCondVisibility('Player.HasAudio'):
                        xbmc.executebuiltin('XBMC.PlayerControl(Previous)')
                    else:
                        xbmc.executebuiltin('Action(Down)')
                elif msg == '3A1C': #MFSW Mode #Context menu
                    if xbmc.getCondVisibility('VideoPlayer.IsFullscreen'):
                        xbmc.executebuiltin('Action(OSD)')
                    else:
                        xbmc.executebuiltin('Action(ContextMenu)')
################ MFSW 5C3
            elif canid == '5C3':
                xbmcgui.Window(10000).setProperty(canid, str(msg))

################ canbus info
            elif canid == '218':
                xbmcgui.Window(10000).setProperty(canid, str(msg))
                if msg ==  msg[2:6] == '0102': #GET.THE.KEY
                    os.system('sudo reboot')
                
            elif canid == '623': # time, data
                xbmcgui.Window(10000).setProperty(canid, str(msg))
                msg = re.sub('[\\s+]', '', msg)
                datatime = 'sudo date %s%s%s%s%s.%s' % (msg[10:12], msg[8:10], msg[2:4], msg[4:6], msg[12:16], msg[6:8])
                os.system(datatime)

            elif canid == '346' or canid == '351':
                xbmcgui.Window(10000).setProperty(canid, str(msg))
                msg = re.sub('[\\s+]', '', msg)
                name = 'speed'
                speed1 = msg[2:4]
                speed2 = msg[4:6]
                value = '%s%s' % (speed2, speed1)
                value = int(value, 16)
                value = value / 200
                value = str(value)
                xbmcgui.Window(10000).setProperty(name, str(value))

            elif canid == '347' or canid == '353' or canid == '35B':
                xbmcgui.Window(10000).setProperty(canid, str(msg))
                msg = re.sub('[\\s+]', '', msg)
                name = 'rpm'
                rpm1 = msg[2:4]
                rpm2 = msg[4:6]
                value = '%s%s' % (rpm2, rpm1)
                value = int(value, 16)
                value = value / 4
                value = str(value)
                xbmcgui.Window(10000).setProperty(name, str(value))

                name = 'temp'
                msg = re.sub('[\\s+]', '', msg)
                temp = msg[6:8]
                value = '%s' % (temp)
                value = int(value, 16)
                value = value * 0.75 - 48
                value = round(value)
                value = str(value)
                xbmcgui.Window(10000).setProperty(name, str(value))
    else:
        sleep(1)
        dumpcan()
