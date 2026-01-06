#!/bin/bash

# Get the ID of the active workspace by querying the activemonitor state
ACTIVE_WORKSPACE_ID=$(hyprctl -j monitors | jq '.[] | select(.focused) | .activeWorkspace.id')

# Use jq to create a string of "dispatch closewindow address:..." commands
COMMANDS=$(hyprctl -j clients | jq -r --argjson ws_id "$ACTIVE_WORKSPACE_ID" '
    .[] | select(.workspace.id == $ws_id) | "dispatch closewindow address:\(.address)"
')

# Execute the combined commands in a single batch
if [ -n "$COMMANDS" ]; then
    hyprctl --batch "$COMMANDS"
fi
