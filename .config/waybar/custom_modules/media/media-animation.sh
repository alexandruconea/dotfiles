#!/usr/bin/env bash

frames=("▂▄▆" "▄▂▆" "▄▆▂" "▆▄▂" "▆▂▄")
i=0

while true; do
    status=$(playerctl status 2>/dev/null)
    if [ "$status" = "Playing" ]; then
        echo "${frames[$i]}"
        i=$(( (i + 1) % ${#frames[@]} ))
        sleep 0.3
    elif [ "$status" = "Paused" ]; then
        echo ""
        sleep 1
    else
        sleep 2
    fi
done
