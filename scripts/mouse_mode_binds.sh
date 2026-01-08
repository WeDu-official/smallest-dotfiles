#!/bin/bash


TOGGLE_FILE="/tmp/hyprland_mouse_mode_toggle"


if [ -f "$TOGGLE_FILE" ]; then

# Mouse mode is ON. Execute the mouse commands using ydotool.

case "$1" in

"Arrow_Up") $HOME/.config/hypr/scripts/move_cursor_rel.sh 0 5 ;;

"Arrow_Down") $HOME/.config/hypr/scripts/move_cursor_rel.sh 0 -5 ;;

"Arrow_Left") $HOME/.config/hypr/scripts/move_cursor_rel.sh -5 0 ;;

"Arrow_Right") $HOME/.config/hypr/scripts/move_cursor_rel.sh 5 0 ;;

"Delete") echo "click left" | dotool ;;

"Page_Down") echo "click right" | dotool ;;

esac

else

# Mouse mode is OFF. Execute the normal key functions.

case "$1" in

"Arrow_Up") echo "key Up" | dotool ;;

"Arrow_Down") echo "key Down" | dotool ;;

"Arrow_Left") echo "key Left" | dotool ;;

"Arrow_Right") echo "key Right" | dotool ;;

"Delete") echo "key Delete" | dotool ;;

"Page_Down") echo "key Page_Down" | dotool ;;

esac

fi 
