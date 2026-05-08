#!/usr/bin/env bash

capacity=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)

# En caso de error de lectura
if [[ -z "$capacity" ]]; then
    echo "󰂑 N/A"
    exit 0
fi

# Asignar ícono de carga o calcular el ícono de descarga
if [[ "$status" == "Charging" ]]; then
    icon="󰂄"
else
    icons=("󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹")
    index=$(( capacity / 10 ))
    
    # Limitar el índice máximo a 10 por seguridad
    [[ $index -gt 10 ]] && index=10
    
    icon="${icons[$index]}"
fi

echo "$icon  $capacity%"
