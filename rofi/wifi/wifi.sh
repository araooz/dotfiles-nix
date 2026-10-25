#!/usr/bin/env bash
# Menu de redes wifi (NetworkManager) con rofi
#   Enter  -> conectar / desconectar      Supr -> olvidar red guardada
#   Ctrl+R -> volver a escanear            Ctrl+W -> encender/apagar wifi
# Volver a lanzarlo mientras esta abierto lo cierra (Super+A hace de toggle).

pkill -x rofi && exit 0

theme="$HOME/.config/rofi/wifi/wifi.rasi"
iface=$(nmcli -t -f DEVICE,TYPE device | awk -F: '$2 == "wifi" { print $1; exit }')

notify() { notify-send -a "Wi-Fi" -i network-wireless "$@"; }
esc() { local s=${1//&/&amp;}; s=${s//</&lt;}; printf '%s' "${s//>/&gt;}"; }

# 󰤯 󰤟 󰤢 󰤥 󰤨  /  con candado 󰤬 󰤡 󰤤 󰤧 󰤪
signal_icon() {
	local open=(󰤯 󰤟 󰤢 󰤥 󰤨) locked=(󰤬 󰤡 󰤤 󰤧 󰤪) i=$(($1 / 20))
	((i > 4)) && i=4
	if [[ $2 == "" || $2 == "--" ]]; then echo "${open[i]}"; else echo "${locked[i]}"; fi
}

scan() {
	notify -t 1500 "Buscando redes..."
	nmcli device wifi rescan 2>/dev/null
	sleep 2
}

connect() {
	local ssid=$1 security=$2 out
	# red guardada: levantar el perfil existente
	if nmcli -t -f NAME connection show | grep -Fxq "$ssid"; then
		notify -t 2000 "Conectando a $ssid..."
		if out=$(nmcli connection up id "$ssid" 2>&1); then
			notify "Conectado" "$ssid"
			return
		fi
		# perfil guardado con contraseña vieja: pedirla de nuevo
		[[ $out == *Secrets* || $out == *secrets* ]] || { notify -u critical "No se pudo conectar" "$out"; return; }
		nmcli connection delete id "$ssid" >/dev/null 2>&1
	fi

	local args=()
	if [[ -n $security && $security != "--" ]]; then
		local pass
		pass=$(rofi -dmenu -password -theme "$theme" \
			-p "" -theme-str 'textbox-prompt-colon { str: "󰌾"; } listview { enabled: false; }' \
			-theme-str 'entry { placeholder: "Contraseña..."; }' \
			-mesg "Contraseña para <b>$(esc "$ssid")</b>" </dev/null) || return
		[[ -z $pass ]] && return
		args=(password "$pass")
	fi

	notify -t 2000 "Conectando a $ssid..."
	if out=$(nmcli device wifi connect "$ssid" "${args[@]}" 2>&1); then
		notify "Conectado" "$ssid"
	else
		# nmcli deja un perfil roto si la contraseña falla
		nmcli connection delete id "$ssid" >/dev/null 2>&1
		notify -u critical "No se pudo conectar a $ssid" "${out#Error: }"
	fi
}

row=0
while true; do
	rows=() kinds=() ssids=() secs=() active=""
	wifi_on=$([[ $(nmcli radio wifi) == enabled ]] && echo 1)

	if [[ $wifi_on ]]; then
		# una fila por SSID: la de mejor señal (o la que esta en uso)
		declare -A best=() sec=() used=()
		while IFS=: read -r inuse signal security ssid; do
			ssid=${ssid//\\:/:}
			[[ -z $ssid ]] && continue
			[[ $inuse == "*" ]] && used[$ssid]=1
			if [[ -z ${best[$ssid]} ]] || ((signal > best[$ssid])); then
				best[$ssid]=$signal sec[$ssid]=$security
			fi
		done < <(nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID device wifi list --rescan no)

		saved=$(nmcli -t -f NAME,TYPE connection show | awk -F: '$2 ~ /wireless/ { print $1 }')

		rows+=("󰖪  Apagar Wi-Fi") kinds+=(toggle) ssids+=("") secs+=("")
		rows+=("󰑓  Buscar redes") kinds+=(scan) ssids+=("") secs+=("")

		while IFS=$'\t' read -r signal ssid; do
			icon=$(signal_icon "$signal" "${sec[$ssid]}")
			tag=""
			grep -Fxq "$ssid" <<<"$saved" && tag="  <span alpha='55%'>󰆓</span>"
			[[ ${used[$ssid]} ]] && { tag="  <span alpha='75%'>conectado</span>"; active=${#rows[@]}; }
			rows+=("$icon  $(esc "$ssid")$tag<span alpha='45%'>  ${signal}%</span>")
			kinds+=(net) ssids+=("$ssid") secs+=("${sec[$ssid]}")
		done < <(for s in "${!best[@]}"; do printf '%s\t%s\n' "${best[$s]}" "$s"; done | sort -t$'\t' -k1,1nr)
		unset best sec used
	else
		rows+=("󰖩  Encender Wi-Fi") kinds+=(toggle) ssids+=("") secs+=("")
	fi
	rows+=("󰒓  Ajustes avanzados (nmtui)") kinds+=(nmtui) ssids+=("") secs+=("")

	# cabecera con la conexion actual
	if [[ ! $wifi_on ]]; then
		mesg="󰖪  Wi-Fi apagado"
	elif [[ -n $active ]]; then
		ip=$(nmcli -g IP4.ADDRESS device show "$iface" | head -1)
		mesg="󰖩  <b>$(esc "${ssids[active]}")</b>   <span alpha='60%'>${ip%/*}</span>"
	else
		mesg="󰤮  Sin conexión"
	fi
	mesg+=$'\n'"<span alpha='55%'><b>⏎</b> conectar  <b>Supr</b> olvidar  <b>^R</b> buscar  <b>^W</b> wifi</span>"

	sel=$(printf '%s\n' "${rows[@]}" | rofi -dmenu -i -markup-rows -format i \
		-p "" -mesg "$mesg" \
		-selected-row "${active:-$row}" ${active:+-a "$active"} \
		-kb-remove-char-forward "Control+d" \
		-kb-remove-word-back "Control+BackSpace" \
		-kb-clear-line "" \
		-kb-custom-1 "Delete" -kb-custom-2 "Control+r" -kb-custom-3 "Control+w" \
		-theme "$theme")
	code=$?
	row=${sel:-0}

	case $code in
		11) scan; continue ;;
		12) [[ $wifi_on ]] && nmcli radio wifi off || nmcli radio wifi on; sleep 1; continue ;;
	esac
	[[ -z $sel ]] && exit 0
	kind=${kinds[sel]} ssid=${ssids[sel]}

	if ((code == 10)); then
		[[ $kind == net ]] && nmcli connection delete id "$ssid" >/dev/null 2>&1 &&
			notify "Red olvidada" "$ssid"
		continue
	fi
	((code == 0)) || exit 0

	case $kind in
		toggle)
			if [[ $wifi_on ]]; then nmcli radio wifi off; exit 0; fi
			nmcli radio wifi on
			sleep 2
			scan
			;;
		scan) scan ;;
		nmtui)
			exec env NEWT_COLORS='root=default,default;window=default,default;border=default,default;textbox=default,default;button=black,white;actbutton=white,black;listbox=default,default;actlistbox=default,default;actsellistbox=black,blue;sellistbox=black,white' \
				kitty --class wifi -o window_padding_width=0 -e nmtui
			;;
		net)
			if [[ $sel == "$active" ]]; then
				nmcli device disconnect "$iface" >/dev/null && notify "Desconectado" "$ssid"
			else
				connect "$ssid" "${secs[sel]}" &
			fi
			exit 0
			;;
	esac
done
