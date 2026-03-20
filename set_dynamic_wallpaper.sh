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
if ! command -v mpvpaper &> /dev/null && ! command -v swww &> /dev/null; then
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
    --file-filter="MP4 files | *.mp4" \
    --file-filter="WebM files | *.webm" \
    --file-filter="MKV files | *.mkv" \
    --file-filter="All files | *")

# Check if a file was selected and the dialog wasn't canceled
if [ -n "$SELECTED_WALLPAPER" ] && [ -f "$SELECTED_WALLPAPER" ]; then
    # Check if it's actually a video file (optional)
    if ! file -b --mime-type "$SELECTED_WALLPAPER" | grep -q "^video/"; then
        dunstify -u critical "Invalid File" "Selected file is not a video. Please select a video file."
        exit 1
    fi

    # The path is valid, update the wallpaper variable file
    echo "$SELECTED_WALLPAPER" > "$WALLPAPER_VAR_FILE"

    # Apply the new video wallpaper
    # Try mpvpaper first, then fall back to swww if available
    if command -v mpvpaper &> /dev/null; then
        # Stop any existing mpvpaper instances
        pkill mpvpaper 2>/dev/null

        # Get monitor names (adjust this based on your setup)
        MONITORS=$(hyprctl monitors | grep -o "Monitor [^ ]*" | cut -d' ' -f2)

        # Apply to all monitors
        for MONITOR in $MONITORS; do
            mpvpaper -o "loop-file=inf" "$MONITOR" "$SELECTED_WALLPAPER" &
        done

        dunstify "Video Wallpaper Updated" "New video wallpaper has been set and saved."

    elif command -v swww &> /dev/null; then
        # swww can handle videos if built with video support
        swww img "$SELECTED_WALLPAPER" --transition-type any

        dunstify "Video Wallpaper Updated" "New video wallpaper has been set and saved."
    else
        dunstify -u critical "Error" "No compatible video wallpaper tool found."
        exit 1
    fi

else
    # The user canceled the selection or the path is invalid
    dunstify -u critical "Invalid Video Path" "No changes were made."
fi
