#!/bin/bash
hyprctl --batch $(hyprctl -j clients | jq -j '.[] | "dispatch closewindow address:\(.address);"');
