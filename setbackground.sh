#!/bin/bash

# Kill existing mpvpaper instances
pkill -9 mpvpaper 2>/dev/null
WIDTH=$1
HEIGHT=$2

if [ "$WIDTH" -eq 0 ] && [ "$HEIGHT" -eq 0 ]; then
    NATIVE="true"
else
    NATIVE="false"
fi

# Wait a moment for processes to die
sleep 0.5

# Get current wallpaper path
WALL=$(cat "$HOME/.config/hypr/current_wallpaper.txt")

# Check if wallpaper file exists
if [ ! -f "$WALL" ]; then
    echo "Error: Wallpaper file not found: $WALL"
    exit 1
fi

# Optimize the video (remove audio, scale to 1080p)
echo "Optimizing video..."

if [ "$NATIVE" = "false" ]; then
echo "non-NATIVE"
ffmpeg -y -i "$WALL" \
       -vf scale=$WIDTH:$HEIGHT \
       -c:v libx264 \
       -crf 23 \
       -preset fast \
       -an \
       "/tmp/tmp_wallpaper.mp4"

# Check if ffmpeg succeeded
if [ $? -ne 0 ]; then
    echo "Error: ffmpeg failed to optimize video"
    exit 1
fi

echo "Starting mpvpaper on both monitors..."

# Monitor 1: HDMI-A-1 (aspect ratio 2560:1080)
mpvpaper -o "--no-audio --loop-file=inf --video-aspect-override=2560:1080" \
         HDMI-A-1 "/tmp/tmp_wallpaper.mp4" &

# Monitor 2: eDP-1 (aspect ratio 1600:900)
mpvpaper -o "--no-audio --loop-file=inf --video-aspect-override=1600:900" \
         eDP-1 "/tmp/tmp_wallpaper.mp4" &
fi


if [ "$NATIVE" = "true" ]; then
echo "NATIVE"
echo "Starting mpvpaper on both monitors..."

# Monitor 1: HDMI-A-1 (aspect ratio 2560:1080)
mpvpaper -o "--no-audio --loop-file=inf --video-aspect-override=2560:1080" \
         HDMI-A-1 "$WALL" &

# Monitor 2: eDP-1 (aspect ratio 1600:900)
mpvpaper -o "--no-audio --loop-file=inf --video-aspect-override=1600:900" \
         eDP-1 "$WALL" &
fi
