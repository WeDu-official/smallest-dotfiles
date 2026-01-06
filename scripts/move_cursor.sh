#!/bin/bash
# The amount to move the cursor
X_MOVE=$1
Y_MOVE=$2
ydotool mousemove -- "$X_MOVE" "$Y_MOVE"
