#!/bin/bash

# Check if a process is already running and terminate it
if [[ -f "/tmp/mouse_move_pid" ]]; then
  PID=$(cat /tmp/mouse_move_pid)
  kill "$PID" &>/dev/null
  rm /tmp/mouse_move_pid
fi

# Arguments: x_offset, y_offset, interval
x_offset=$1
y_offset=$2
interval=$3

# Start the continuous movement script in the background
$HOME/.config/hypr/scripts/continuous_cursor_move.sh "$x_offset" "$y_offset" "$interval" &
echo $! > /tmp/mouse_move_pid
