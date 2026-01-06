#!/bin/bash

TOGGLE_FILE="/tmp/hyprland_mouse_mode_toggle"

if [ -f "$TOGGLE_FILE" ]; then
  # If the file exists, the mode is ON, so turn it OFF
  rm "$TOGGLE_FILE"
  notify-send "Mouse Mode" "OFF"
else
  # If the file doesn't exist, the mode is OFF, so turn it ON
  touch "$TOGGLE_FILE"
  notify-send "Mouse Mode" "ON"
fi
