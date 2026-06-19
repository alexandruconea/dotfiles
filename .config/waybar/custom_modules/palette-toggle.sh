#!/bin/bash
STATE_FILE="$HOME/.local/state/wallust-enabled"
STYLE="$HOME/.config/waybar/style.css"

STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "enabled")

apply_neutral() {
    sed -i "s|@define-color foreground .*|@define-color foreground #ffffff;|" "$STYLE"
    sed -i "s|@define-color highlight .*|@define-color highlight  #ffffff;|" "$STYLE"
    sed -i "s|@define-color w-warm .*|@define-color w-warm    #ffffff;|" "$STYLE"
    sed -i "s|@define-color w-light .*|@define-color w-light   #ffffff;|" "$STYLE"
    sed -i "s|@define-color w-neutral .*|@define-color w-neutral #cccccc;|" "$STYLE"
    sed -i "s|@define-color w-muted .*|@define-color w-muted   #888888;|" "$STYLE"
    sed -i "s|@define-color w-dark .*|@define-color w-dark    #555555;|" "$STYLE"
    hyprctl eval "hl.config({general = {col = {active_border = 'rgba(ffffffee)', inactive_border = 'rgba(ffffff33)'}}})" 2>/dev/null
    pkill -SIGUSR2 waybar 2>/dev/null
}

restore_palette() {
    LAST="$HOME/.config/wallust/last-wallpaper"
    IMAGE=$(readlink -f "$LAST" 2>/dev/null)
    if [ -n "$IMAGE" ] && [ -f "$IMAGE" ]; then
        ~/.config/waybar/custom_modules/wallust-apply.sh "$IMAGE" &
    fi
}

if [ "$1" = "--toggle" ]; then
    if [ "$STATE" = "enabled" ]; then
        echo "disabled" > "$STATE_FILE"
        apply_neutral
    else
        echo "enabled" > "$STATE_FILE"
        restore_palette
    fi
    pkill -SIGRTMIN+9 waybar 2>/dev/null
    exit 0
fi

if [ "$STATE" = "enabled" ]; then
    printf '{"text":"󰏘","class":"enabled","tooltip":"Palette: ON"}\n'
else
    printf '{"text":"󰏙","class":"disabled","tooltip":"Palette: OFF"}\n'
fi
