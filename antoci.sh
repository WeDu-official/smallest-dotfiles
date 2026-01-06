#!/bin/bash

# --- Configuration ---
FILE="~/.config/hypr/antoc.txt"
INCREMENT=0.05
MAX_VALUE=1.00
HYPR_VAR="decoration:active_opacity"

# Read current value
current_value=$(cat "$FILE")

# Use bc for reliable floating-point comparison and check against max
if echo "$current_value < $MAX_VALUE" | bc -l | grep -q 1; then

    # Calculate new value (ensuring two decimal places with scale=2)
    new_value=$(echo "scale=2; $current_value + $INCREMENT" | bc -l)

    # Cap the value at the maximum (1.00)
    if echo "$new_value > $MAX_VALUE" | bc -l | grep -q 1; then
        new_value=$MAX_VALUE
    fi

    # Write the new value back to the file
    echo "$new_value" > "$FILE"

    # ACTION: Apply the change instantly using hyprctl
    # NEW (Correct for global setting)
    hyprctl keyword "$HYPR_VAR" "$new_value"

else
    # Value is already at maximum, do nothing
    exit 0
fi
