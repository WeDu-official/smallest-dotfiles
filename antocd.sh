#!/bin/bash

# --- Configuration ---
FILE="~/.config/hypr/antoc.txt"
DECREMENT=0.05
MIN_VALUE=0.00
HYPR_VAR="decoration:active_opacity"

# Read current value
current_value=$(cat "$FILE")

# Use bc for reliable floating-point comparison and check against min
if echo "$current_value > $MIN_VALUE" | bc -l | grep -q 1; then

    # Calculate new value (ensuring two decimal places with scale=2)
    new_value=$(echo "scale=2; $current_value - $DECREMENT" | bc -l)

    # Cap the value at the minimum (0.00)
    if echo "$new_value < $MIN_VALUE" | bc -l | grep -q 1; then
        new_value=$MIN_VALUE
    fi

    # Write the new value back to the file
    echo "$new_value" > "$FILE"

    # ACTION: Apply the change instantly using hyprctl
    # NEW (Correct for global setting)
    hyprctl keyword "$HYPR_VAR" "$new_value"

else
    # Value is already at minimum, do nothing
    exit 0
fi
