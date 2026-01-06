#!/bin/bash

USB_KEYBOARD="09da:e664"
KEYBINDS_USB_FILE="$HOME/.config/hypr/keybinds_usb.conf"
KEYBINDS_LAPTOP_FILE="$HOME/.config/hypr/keybinds_laptop.conf"
CONFIG_TEMP_FILE="$HOME/.config/hypr/temp_keybinds.conf"
HYPRLAND_CONFIG="$HOME/.config/hypr/hyprland.conf"

# Remove old keybinds from main config before sourcing new ones
sed -i '/binde=/d' "$HYPRLAND_CONFIG"
sed -i '/bind=/d' "$HYPRLAND_CONFIG"

# Check if the USB keyboard is connected
if hyprctl devices | grep -q "$USB_KEYBOARD"; then
    cat "$KEYBINDS_USB_FILE" > "$CONFIG_TEMP_FILE"
    notify-send "Hyprland" "Loading USB keyboard keybinds."
else
    cat "$KEYBINDS_LAPTOP_FILE" > "$CONFIG_TEMP_FILE"
    notify-send "Hyprland" "Loading laptop keyboard keybinds."
fi

# Source the temporary keybinds file in Hyprland
hyprctl --batch "source $CONFIG_TEMP_FILE"
