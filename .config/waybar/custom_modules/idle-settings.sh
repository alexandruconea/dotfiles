#!/bin/bash

STATE="$HOME/.local/state/idle-settings"
CONF="$HOME/.config/hypr/hypridle.conf"

# Defaults
LOCK_SEC=300
DPMS_SEC=600

[ -f "$STATE" ] && source "$STATE"

sec_to_label() {
    [ "$1" = "0" ] && echo "Never" && return
    local m=$(( $1 / 60 ))
    [ "$m" -eq 1 ] && echo "1 min" || echo "${m} min"
}

sec_to_row() {
    case "$1" in
        0)    echo 0 ;;
        60)   echo 1 ;;
        120)  echo 2 ;;
        180)  echo 3 ;;
        300)  echo 4 ;;
        600)  echo 5 ;;
        900)  echo 6 ;;
        1200) echo 7 ;;
        1800) echo 8 ;;
        3600) echo 9 ;;
        *)    echo 4 ;;
    esac
}

label_to_sec() {
    case "$1" in
        "Never")  echo 0 ;;
        "1 min")  echo 60 ;;
        "2 min")  echo 120 ;;
        "3 min")  echo 180 ;;
        "5 min")  echo 300 ;;
        "10 min") echo 600 ;;
        "15 min") echo 900 ;;
        "20 min") echo 1200 ;;
        "30 min") echo 1800 ;;
        "1 hour") echo 3600 ;;
        *) echo "" ;;
    esac
}

TIME_OPTIONS="Never\n1 min\n2 min\n3 min\n5 min\n10 min\n15 min\n20 min\n30 min\n1 hour"

write_conf() {
    {
        echo "general {"
        echo "    lock_cmd = pidof hyprlock || hyprlock"
        echo "    before_sleep_cmd = loginctl lock-session"
        echo "}"
        echo ""

        if [ "$LOCK_SEC" -gt 0 ]; then
            echo "listener {"
            echo "    timeout = $LOCK_SEC"
            echo "    on-timeout = loginctl lock-session"
            echo "}"
            echo ""
        fi

        if [ "$DPMS_SEC" -gt 0 ]; then
            echo "listener {"
            echo "    timeout = $DPMS_SEC"
            echo "    on-timeout = hyprctl dispatch dpms off"
            echo "    on-resume = hyprctl dispatch dpms on"
            echo "}"
        fi
    } > "$CONF"

    pkill hypridle 2>/dev/null
    sleep 0.3
    hypridle &
    disown
}

LOCK_LABEL=$(sec_to_label "$LOCK_SEC")
DPMS_LABEL=$(sec_to_label "$DPMS_SEC")

CHOICE=$(printf "󰌾  Lock Screen: $LOCK_LABEL\n󰍹  Display Off: $DPMS_LABEL" \
    | rofi -dmenu \
        -p "Idle Settings" \
        -theme ~/.config/rofi/powermenu.rasi \
        -theme-str 'listview { lines: 2; }' \
        -theme-str 'window { width: 300px; }')

[ -z "$CHOICE" ] && exit 0

case "$CHOICE" in
    *"Lock Screen"*)
        ROW=$(sec_to_row "$LOCK_SEC")
        NEW=$(printf "$TIME_OPTIONS" \
            | rofi -dmenu \
                -p "Lock after" \
                -theme ~/.config/rofi/powermenu.rasi \
                -theme-str 'listview { lines: 10; }' \
                -theme-str 'window { width: 200px; }' \
                -selected-row "$ROW")
        [ -z "$NEW" ] && exit 0
        SECS=$(label_to_sec "$NEW")
        [ -z "$SECS" ] && exit 0
        LOCK_SEC=$SECS
        ;;
    *"Display Off"*)
        ROW=$(sec_to_row "$DPMS_SEC")
        NEW=$(printf "$TIME_OPTIONS" \
            | rofi -dmenu \
                -p "Display off after" \
                -theme ~/.config/rofi/powermenu.rasi \
                -theme-str 'listview { lines: 10; }' \
                -theme-str 'window { width: 200px; }' \
                -selected-row "$ROW")
        [ -z "$NEW" ] && exit 0
        SECS=$(label_to_sec "$NEW")
        [ -z "$SECS" ] && exit 0
        DPMS_SEC=$SECS
        ;;
esac

echo "LOCK_SEC=$LOCK_SEC" > "$STATE"
echo "DPMS_SEC=$DPMS_SEC" >> "$STATE"

write_conf
