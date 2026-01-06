#!/bin/bash

# A temporary file to signal the script to stop
STOP_FILE="/tmp/mouse_move_stop"

# Check if a previous instance is running and stop it
if [ -f "$STOP_FILE" ]; then
    rm "$STOP_FILE"
    exit 0
fi

# Set the stop file for this instance
touch "$STOP_FILE"

x_offset=$1
y_offset=$2
interval=0.01  # A very short interval for smooth movement

# A loop that continues as long as the temporary file exists
while [ -f "$STOP_FILE" ]; do
    ydotool mousemove -- "$x_offset" "$y_offset"
    sleep "$interval"
done
