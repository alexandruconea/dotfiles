#!/bin/bash

get_profile() {
    EPP=$(cat /sys/devices/system/cpu/cpufreq/policy0/energy_performance_preference 2>/dev/null)
    GOV=$(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_governor 2>/dev/null)
    if [ "$GOV" = "performance" ] || [ "$EPP" = "performance" ]; then
        echo "performance"
    elif [ "$EPP" = "power" ] || [ "$EPP" = "balance_power" ]; then
        echo "power-saver"
    else
        echo "balanced"
    fi
}

if [ "$1" = "--select" ]; then
    CURRENT=$(get_profile)
    case "$CURRENT" in
        performance) ROW=0 ;;
        balanced)    ROW=1 ;;
        power-saver) ROW=2 ;;
        *)           ROW=1 ;;
    esac

    CHOICE=$(printf "󱐌  Performance\n󰾅  Balanced\n󰌪  Power Saver" \
        | rofi -dmenu \
            -p "Power Profile" \
            -theme ~/.config/rofi/powermenu.rasi \
            -theme-str 'listview { lines: 3; }' \
            -theme-str 'window { width: 240px; }' \
            -selected-row "$ROW" \
        | grep -oP '(Performance|Balanced|Power Saver)')

    case "$CHOICE" in
        Performance)   PROFILE_ID="performance" ;;
        Balanced)      PROFILE_ID="balanced" ;;
        "Power Saver") PROFILE_ID="power-saver" ;;
    esac

    if [ -n "$PROFILE_ID" ]; then
        sudo /usr/local/bin/set-power-profile "$PROFILE_ID"
        mkdir -p "$HOME/.local/state"
        echo "$PROFILE_ID" > "$HOME/.local/state/power-profile"
    fi

    pkill -SIGRTMIN+8 waybar 2>/dev/null
    exit 0
fi

PROFILE=$(get_profile)
case "$PROFILE" in
    performance)  ICON="󱐌"; CLASS="performance";  LABEL="Performance" ;;
    balanced)     ICON="󰾅"; CLASS="balanced";      LABEL="Balanced" ;;
    power-saver)  ICON="󰌪"; CLASS="power-saver";  LABEL="Power Saver" ;;
esac

printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$ICON" "$CLASS" "$LABEL"
