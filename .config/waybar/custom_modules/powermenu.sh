#!/usr/bin/env bash

options=" Lock\n Logout\n Sleep\n Restart\n Shutdown"

chosen=$(echo -e "$options" | rofi -dmenu \
    -p "Power" \
    -theme-str 'window { width: 200px; }' \
    -theme-str 'listview { lines: 5; }')

case "$chosen" in
    " Lock")    pkill rofi; sleep 0.5; hyprlock ;;
    " Logout")  hyprctl dispatch exit ;;
    " Sleep")   systemctl suspend ;;
    " Restart") systemctl reboot ;;
    " Shutdown") systemctl poweroff ;;
esac
