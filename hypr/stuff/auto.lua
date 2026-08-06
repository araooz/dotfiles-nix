-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
    -- Script para reiniciar portales y evitar cierres de apps
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user restart pipewire pipewire-pulse wireplumber")

    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("zapzap")
    hl.exec_cmd("zen")

    -- portapapeles
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("rm ~/.cache/cliphist/db") -- para que se reinicie el historial cada q prendo

    -- brillo
    hl.exec_cmd("swayosd-server")

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
