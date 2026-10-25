#!/usr/bin/env bash
# Historial del portapapeles (cliphist) con rofi
#   Enter -> copiar     Supr -> borrar del historial
# Las imagenes se muestran con miniatura, formato, resolucion y peso.

dir="$HOME/.config/rofi/clipboard"
thumbs="$HOME/.cache/cliphist/thumbs"
mkdir -p "$thumbs"
menu=$(mktemp)
trap 'rm -f "$menu"' EXIT

# cliphist identifica el elemento por el id antes del tab
by_id() { printf '%s\t\n' "$1" | cliphist "$2"; }

row=0
while true; do
	ids=()
	: >"$menu"
	while IFS=$'\t' read -r id content; do
		ids+=("$id")
		# [[ binary data 34 KiB png 1920x1080 ]]
		if [[ $content =~ ^\[\[\ binary\ data\ (.+)\ ([a-z]+)\ ([0-9]+x[0-9]+)\ \]\]$ ]]; then
			size="${BASH_REMATCH[1]}"
			ext="${BASH_REMATCH[2]}"
			res="${BASH_REMATCH[3]/x/×}"
			thumb="$thumbs/$id.$ext"
			[[ -s $thumb ]] || by_id "$id" decode >"$thumb"
			printf '%s · %s · %s\0icon\x1f%s\n' "${ext^^}" "$res" "$size" "$thumb" >>"$menu"
		else
			printf '%s\0icon\x1f%s\n' "$content" "$dir/text.svg" >>"$menu"
		fi
	done < <(cliphist list)

	sel=$(rofi -dmenu -i -format i \
		-p "busca papaish" \
		-mesg "<b>⏎</b> copiar    <b>Supr</b> borrar" \
		-selected-row "$row" \
		-kb-remove-char-forward "Control+d" \
		-kb-custom-1 "Delete" \
		-theme "$dir/clipboard.rasi" <"$menu")
	code=$?

	[[ -z $sel ]] && exit 0
	id="${ids[$sel]}"

	case $code in
		0) # copiar
			by_id "$id" decode | wl-copy
			exit 0
			;;
		10) # Supr: borrar y volver a abrir en la misma posicion
			by_id "$id" delete
			rm -f "$thumbs/$id".*
			row=$sel
			((row >= ${#ids[@]} - 1 && row > 0)) && row=$((row - 1))
			;;
		*) exit 0 ;;
	esac
done
