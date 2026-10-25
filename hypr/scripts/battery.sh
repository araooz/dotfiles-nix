#!/usr/bin/env bash
# Bateria para hyprlock, con los mismos iconos y colores que waybar
BAT_PATH="/sys/class/power_supply/BAT0"

capacity=$(cat "$BAT_PATH/capacity")
status=$(cat "$BAT_PATH/status")

# mismos iconos que waybar/config (0%, 10%, ..., 100%)
icons=(󰂎 󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹)
icon=${icons[$(((capacity + 5) / 10))]}

# colores generados por nix/theme.nix
color() { sed -n "s/^\$$1 *= *rgb(\(.*\))/\1/p" ~/.config/hypr/colors.conf; }

# porcentaje alineado a 3 cifras (como {capacity: >3} en waybar): el ancho no cambia
text=$(printf '%s %3s%%' "$icon" "$capacity")
if [ "$status" = "Charging" ]; then
    echo "<span color='#$(color green)'>$text</span>"
elif [ "$capacity" -le 15 ]; then
    echo "<span color='#$(color red)'>$text</span>"
else
    echo "$text"
fi
