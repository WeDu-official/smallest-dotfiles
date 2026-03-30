#!/bin/bash

# Define the path to your wallpaper variable file
WALLPAPER_VAR_FILE="$HOME/.config/hypr/current_wallpaper.txt"

# Check if Zenity is installed. If not, inform the user and exit.
if ! command -v zenity &> /dev/null; then
    dunstify -u critical "Error" "Zenity is not installed. Please install it to use this script."
    exit 1
fi

# Check if video wallpaper tool is installed
# Using mpvpaper as an example (you can change this to your preferred video wallpaper tool)
if ! command -v mpvpaper &> /dev/null; then
    dunstify -u critical "Error" "No video wallpaper tool found. Please install mpvpaper or swww."
    exit 1
fi

# Get the directory of the current wallpaper from the variable file
if [ -f "$WALLPAPER_VAR_FILE" ]; then
    CURRENT_WALLPAPER=$(cat "$WALLPAPER_VAR_FILE")
    if [ -f "$CURRENT_WALLPAPER" ]; then
        CURRENT_WALLPAPER_DIR=$(dirname "$CURRENT_WALLPAPER")
    else
        CURRENT_WALLPAPER_DIR="$HOME/Videos"
    fi
else
    CURRENT_WALLPAPER_DIR="$HOME/Videos"
fi

# Create Videos directory if it doesn't exist
mkdir -p "$HOME/Videos"

# Use Zenity to open a graphical file browser for video files
SELECTED_WALLPAPER=$(zenity --file-selection \
    --title="Select a Video Wallpaper" \
    --filename="$CURRENT_WALLPAPER_DIR/" \
    --file-filter="Video files | *.mp4 *.mkv *.avi *.mov *.wmv *.flv *.webm *.m4v *.mpg *.mpeg" \
    --file-filter="Image files | *.jpg *.jpeg *.png *.gif *.bmp *.webp *.tiff *.svg" \
    --file-filter="MP4 files | *.mp4" \
    --file-filter="WebM files | *.webm" \
    --file-filter="MKV files | *.mkv" \
    --file-filter="JPEG files | *.jpg *.jpeg" \
    --file-filter="PNG files | *.png" \
    --file-filter="GIF files | *.gif" \
    --file-filter="WebP files | *.webp" \
    --file-filter="SVG files | *.svg" \
    --file-filter="All files | *")

# Check if a file was selected and the dialog wasn't canceled
if [ -n "$SELECTED_WALLPAPER" ] && [ -f "$SELECTED_WALLPAPER" ]; then
    # The path is valid, update the wallpaper variable file
    echo "$SELECTED_WALLPAPER" > "$WALLPAPER_VAR_FILE"

    dunstify "Video Wallpaper Updated" "New video wallpaper has been saved and can be set."

else
    # The user canceled the selection or the path is invalid
    dunstify -u critical "Invalid Video Path" "No changes were made."
fi
