#!/bin/bash


chosen=$(echo -e "Logout\nShutdown\nReboot\nSuspend" | rofi -dmenu -i -p "Power:")



case "$chosen" in


"Logout") hyprctl dispatch exit ;;


"Shutdown") systemctl poweroff ;;


"Reboot") systemctl reboot ;;


"Suspend") systemctl suspend ;;


*) exit 1 ;;


esac 
