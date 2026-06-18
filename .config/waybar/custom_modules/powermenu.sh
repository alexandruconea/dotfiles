#!/usr/bin/env bash

options=" Lock\n Sleep\n Restart\n Shutdown"

chosen=$(echo -e "$options" | rofi -dmenu \
    -p "Power" \
    -theme ~/.config/rofi/powermenu.rasi)

case "$chosen" in
    " Lock")     pkill rofi; sleep 0.5; hyprlock ;;
    " Sleep")    systemctl suspend ;;
    " Restart")  systemctl reboot ;;
    " Shutdown") systemctl poweroff ;;
esac
