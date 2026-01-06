#!/bin/bash

case "$1" in
  "F9") brightnessctl s 5%+ ;;
  "F10") brightnessctl s 5%- ;;
  "F3") pamixer --increase 5 ;;
  "F2") pamixer --decrease 5 ;;
  "F1") pamixer --toggle-mute ;;
  "F5") pactl set-source-mute @DEFAULT_SOURCE@ toggle ;;
  "XF86MonBrightnessDown") brightnessctl s 5%- ;;
  "XF86MonBrightnessUp") brightnessctl s 5%+ ;;
  "XF86AudioMute") pamixer --toggle-mute ;;
  "XF86AudioLowerVolume") pamixer --decrease 5 ;;
  "XF86AudioRaiseVolume") pamixer --increase 5 ;;
  "XF86AudioMicMute") pactl set-source-mute @DEFAULT_SOURCE@ toggle ;;
esac
