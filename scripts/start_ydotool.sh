#!/bin/bash

# This script checks if ydotool is running and starts it if not.
if ! pgrep -x "ydotool" > /dev/null; then
    # Set the runtime directory for ydotool to work properly.
    export YDOTOOL_SOCKET="/tmp/ydotool_socket"
    ydotool &
fi
