#!/bin/bash

# Icon only for waybar display
sink_icon() {
    case "$1" in
        *HiFi__SPDIF*)      echo "󰓃" ;;
        *HiFi__Speaker*)    echo "󰓃" ;;
        *HiFi__Headphones*) echo "󰋋" ;;
        *HyperX*)           echo "󰋋" ;;
        *Scarlett*)         echo "󰾰" ;;
        *bluez*)            echo "󰂯" ;;
        *)                  echo "󰓃" ;;
    esac
}

# Friendly name for rofi menu
friendly_name() {
    case "$1" in
        *HiFi__SPDIF*)      echo "󰓃 SPDIF" ;;
        *HiFi__Speaker*)    echo "󰓃 USB Speakers" ;;
        *HiFi__Headphones*) echo "󰋋 USB Headphones" ;;
        *HyperX*)           echo "󰋋 HyperX Cloud III" ;;
        *Scarlett*)         echo "󰾰 Focusrite Scarlett" ;;
        *bluez*)            echo "󰂯 Bluetooth" ;;
        *)                  echo "󰓃 $1" ;;
    esac
}

default_sink=$(pactl get-default-sink)

if [ "$1" = "--select" ]; then
    # Build menu entries
    entries=""
    declare -A sink_map
    while IFS=$'\t' read -r _ name _; do
        label=$(friendly_name "$name")
        [ "$name" = "$default_sink" ] && label="$label  ✓"
        entries="$entries$label\n"
        sink_map["$label"]="$name"
        sink_map["$label  ✓"]="$name"
    done < <(pactl list short sinks)

    chosen=$(echo -e "${entries%\\n}" | rofi -dmenu \
        -p "Audio Output" \
        -theme ~/.config/rofi/powermenu.rasi \
        -theme-str 'listview { lines: 6; }')

    [ -z "$chosen" ] && exit 0

    # Find sink name for chosen label (strip ✓ if present)
    clean=$(echo "$chosen" | sed 's/  ✓//')
    while IFS=$'\t' read -r _ name _; do
        label=$(friendly_name "$name")
        if [ "$label" = "$clean" ]; then
            pactl set-default-sink "$name"
            # Move all active streams to new sink
            pactl list short sink-inputs | awk '{print $1}' | while read -r input; do
                pactl move-sink-input "$input" "$name" 2>/dev/null
            done
            break
        fi
    done < <(pactl list short sinks)
else
    # Just print current output icon for waybar
    sink_icon "$default_sink"
fi
