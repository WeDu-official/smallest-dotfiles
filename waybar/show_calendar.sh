#!/bin/bash

# Check if yad is installed
if command -v yad &> /dev/null; then
    # Use yad for a nice calendar popup
    yad --calendar \
        --title="Calendar" \
        --width=300 \
        --height=250 \
        --button="Close:0" \
        --text="<b>$(date '+%A, %B %d, %Y')</b>" \
        --center \
        --timeout=15 \
        --timeout-indicator=bottom
elif command -v zenity &> /dev/null; then
    # Use zenity as fallback
    zenity --calendar \
        --title="Calendar" \
        --text="$(date '+%A, %B %d, %Y')" \
        --width=300 \
        --height=250
else
    # Fallback to notify-send if neither is available
    notify-send "Date Info" "$(date '+%A, %B %d, %Y')"
fi
