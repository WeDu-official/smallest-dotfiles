#!/bin/bash

# This script performs a continuous series of very small mouse movements
# to simulate a real mouse hovering over an item.

# Number of times to loop
LOOPS=50

# Tiny mouse movement
X_MOVE=1
Y_MOVE=0

# Pause between movements
SLEEP_TIME=0.01

for i in $(seq 1 $LOOPS); do
    # Move the mouse a tiny bit (1 pixel right, 0 pixels down)
    echo "mousemove $X_MOVE $Y_MOVE" | dotool
    sleep $SLEEP_TIME
done

# Finally, move the mouse back to its original position
echo "mousemove -$((X_MOVE * LOOPS)) -$((Y_MOVE * LOOPS))" | dotool
