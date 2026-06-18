#!/usr/bin/env bash

position=$(playerctl metadata --format '{{duration(position)}}' 2>/dev/null)
length=$(playerctl metadata --format '{{duration(mpris:length)}}' 2>/dev/null)

if [ -z "$position" ]; then
    exit 0
elif [ "$length" = "0:00" ] || [ -z "$length" ]; then
    echo "$position"
else
    echo "$position/$length"
fi
