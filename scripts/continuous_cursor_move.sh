#!/bin/bash

# Arguments: x_offset, y_offset, interval (in seconds)
x_offset=$1
y_offset=$2
interval=$3

# Loop indefinitely
while true; do
  # Check if the process should terminate
  if [[ -f "/tmp/stop_mouse_move" ]]; then
    rm /tmp/stop_mouse_move
    exit 0
  fi

  # Move the cursor
  ydotool mousemove -- "$x_offset" "$y_offset"
  
  # Wait for a short interval before the next move
  sleep "$interval"
done
