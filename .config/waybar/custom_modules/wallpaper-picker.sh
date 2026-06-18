#!/bin/bash
# Selectează wallpaper din ~/Wallpapers cu rofi și aplică wallust

WALLPAPER_DIR="$HOME/Wallpapers"

chosen=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" \) \
    | sort \
    | xargs -I{} basename {} \
    | rofi -dmenu \
        -p "Wallpaper" \
        -theme ~/.config/rofi/powermenu.rasi \
        -theme-str 'listview { lines: 10; }' \
        -theme-str 'window { width: 300px; }')

[ -z "$chosen" ] && exit 0

~/.config/waybar/custom_modules/wallust-apply.sh "$WALLPAPER_DIR/$chosen"
