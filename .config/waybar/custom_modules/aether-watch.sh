#!/bin/bash

mkdir -p "$HOME/.config/aether/theme"

while true; do
    inotifywait -e close_write "$HOME/.config/aether/theme/colors.toml" 2>/dev/null
    sleep 0.5
    ~/.config/waybar/custom_modules/aether-apply.sh
done
