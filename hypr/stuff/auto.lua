-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
	-- Exportar variables de entorno necesarias para portales XDG y OBS screencapture
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE")
	hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE")

	-- panel lateral (wifi, bluetooth, notificaciones): servicio en nix/home.nix que se reinicia solo.
	-- Se exporta el entorno en el mismo comando para que no arranque antes de tener WAYLAND_DISPLAY.
	hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP && systemctl --user restart quickshell")

	-- Activar graphical-session.target via NixOS fake target (los portales XDG dependen de esto)
	hl.exec_cmd("systemctl --user start nixos-fake-graphical-session.target")

	-- Reiniciar portales XDG para que arranquen correctamente con la sesión gráfica
	hl.exec_cmd("systemctl --user restart xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-desktop-portal")

	hl.exec_cmd("systemctl --user restart pipewire pipewire-pulse wireplumber")

	hl.exec_cmd("waybar")
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("zapzap")
	hl.exec_cmd("zen")

	-- portapapeles
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
	hl.exec_cmd("rm -rf ~/.cache/cliphist/db ~/.cache/cliphist/thumbs") -- para que se reinicie el historial  cada q prendo

	-- Comando para forzar el cursor al iniciar
	hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
end)

-------------------
----- AUTOEND -----
-------------------
hl.on("hyprland.shutdown", function()
	hl.exec_cmd("docker compose down")
	hl.exec_cmd("bluetoothctl power off")
end)
