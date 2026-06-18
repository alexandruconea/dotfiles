#!/bin/bash
while true; do
    file=$(inotifywait -e close_write --format '%f' \
        ~/.config/waybar/config.jsonc \
        ~/.config/waybar/style.css 2>/dev/null)
    if [[ "$file" == "style.css" ]]; then
        killall -SIGUSR2 waybar
    else
        killall waybar
        waybar &
    fi
done
