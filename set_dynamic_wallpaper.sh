#!/bin/bash

# Define the path to your wallpaper variable file
WALLPAPER_VAR_FILE="$HOME/.config/hypr/current_wallpaper.txt"

# Check if Zenity is installed. If not, inform the user and exit.
if ! command -v zenity &> /dev/null; then
    dunstify -u critical "Error" "Zenity is not installed. Please install it to use this script."
    exit 1
fi

# Check if awww is installed
if ! command -v awww &> /dev/null; then
    dunstify -u critical "Error" "awww is not installed. Please install it to use this script."
    exit 1
fi

# Get the directory of the current wallpaper from the variable file
if [ -f "$WALLPAPER_VAR_FILE" ]; then
    CURRENT_WALLPAPER=$(cat "$WALLPAPER_VAR_FILE")
    if [ -f "$CURRENT_WALLPAPER" ]; then
        CURRENT_WALLPAPER_DIR=$(dirname "$CURRENT_WALLPAPER")
    else
        CURRENT_WALLPAPER_DIR="$HOME/Pictures"
    fi
else
    CURRENT_WALLPAPER_DIR="$HOME/Pictures"
fi

# Create Pictures directory if it doesn't exist
mkdir -p "$HOME/Pictures"

# Use Zenity to open a graphical file browser
SELECTED_WALLPAPER=$(zenity --file-selection \
    --title="Select a Wallpaper" \
    --filename="$CURRENT_WALLPAPER_DIR/" \
    --file-filter="Image files | *.jpg *.jpeg *.png *.gif *.bmp *.webp *.svg" \
    --file-filter="All files | *")

# Check if a file was selected and the dialog wasn't canceled
if [ -n "$SELECTED_WALLPAPER" ] && [ -f "$SELECTED_WALLPAPER" ]; then
    # The path is valid, update the wallpaper variable file
    echo "$SELECTED_WALLPAPER" > "$WALLPAPER_VAR_FILE"

    # Apply the new wallpaper immediately with awww
    awww --image "$SELECTED_WALLPAPER"

    dunstify "Wallpaper Updated" "New wallpaper has been set and saved."
else
    # The user canceled the selection or the path is invalid
    dunstify -u critical "Invalid Wallpaper Path" "No changes were made."
fi
