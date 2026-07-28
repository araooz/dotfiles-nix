#!/usr/bin/env bash
BAT_PATH="/sys/class/power_supply/BAT0"

capacity=$(cat "$BAT_PATH/capacity")
status=$(cat "$BAT_PATH/status")

if [ "$status" = "Charging" ]; then
    icon=""
elif [ "$capacity" -ge 90 ]; then
    icon=""
elif [ "$capacity" -ge 70 ]; then
    icon=""
elif [ "$capacity" -ge 40 ]; then
    icon=""
elif [ "$capacity" -ge 15 ]; then
    icon=""
else
    icon=""
fi

echo "$icon  $capacity%"
