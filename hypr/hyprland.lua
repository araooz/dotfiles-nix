-- ============================================================
-- hyprland.lua
-- Traducción del hyprland.conf clásico a la nueva sintaxis Lua
-- introducida en Hyprland 0.55 (hyprlang -> lua).
-- Referencia: https://wiki.hypr.land/Configuring/Start/
-- ============================================================

-------------------
---- AUTOSTART ----
-------------------
-- Antes: exec-once = ...
-- Ahora: se ejecutan dentro del evento "hyprland.start"
-- hl.exec_cmd() ya lanza el proceso de forma asíncrona (no hace falta & disown)
hl.on("hyprland.start", function()
    -- Script para reiniciar portales y evitar cierres de apps
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user restart pipewire pipewire-pulse wireplumber")

    hl.exec_cmd("waybar & hyprpaper") -- & hyprlock
    hl.exec_cmd("zapzap")
    hl.exec_cmd("zen")

    -- portapapeles
    -- Iniciar el centinela de cliphist al arrancar
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("rm ~/.cache/cliphist/db") -- para que se reinicie el historial cada q prendo

    -- brillo
    hl.exec_cmd("swayosd-server")

    -- Comando para forzar el cursor al iniciar
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
end)

-- Antes: exec-shutdown = ...
-- Ahora: evento "hyprland.shutdown"
hl.on("hyprland.shutdown", function()
    hl.exec_cmd("docker compose down")
    hl.exec_cmd("bluetoothctl power off")
end)

------------------
---- MONITORS ----
------------------
-- https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@144",
    position = "auto",
    scale    = 1,
})

---------------------
---- MY PROGRAMS ----
---------------------
local terminal    = "kitty"
local fileManager = "thunar"

-- Atajo de teclado para abrir el historial del portapapeles
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd(
    'cliphist list | rofi -dmenu -display-columns 2 -p "busca papaish" -theme /home/falo/.config/rofi/launchers/type-1/style-5.rasi | cliphist decode | wl-copy'
))

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
-- Definir variables de entorno para el cursor
hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE", "24")

-----------------------
----- PERMISSIONS -----
-----------------------
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Nota: los cambios de "ecosystem"/permisos requieren reiniciar Hyprland
hl.config({
    ecosystem = {
        -- enforce_permissions = true,
        no_update_news = true,
    },
})

hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

-----------------------
---- LOOK AND FEEL ----
-----------------------
-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in          = 4,
        gaps_out         = 4,
        border_size      = 2,

        col              = {
            -- rgba(bbbb0088) #rgba(880808ee) rgba(080899ee) 45deg
            active_border   = "rgba(7dcfffee)",
            inactive_border = "rgba(7dcfff22)",
        },

        -- Set to true enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing    = false,

        layout           = "dwindle",
    },

    decoration = {
        rounding         = 5,
        rounding_power   = 5,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 0.8,

        shadow           = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },

        -- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Blur/
        blur             = {
            enabled  = true,
            size     = 3,
            passes   = 1,

            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true, -- yes, please :)
    },
})

-- Curvas y animaciones por defecto
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- descomenta todo si quieres usarlo.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({ name = "no-gaps-wtv1", match = { float = false, workspace = "w[tv1]" }, border_size = 0, rounding = 0 })
-- hl.window_rule({ name = "no-gaps-f1",   match = { float = false, workspace = "f[1]" },   border_size = 0, rounding = 0 })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
hl.config({
    dwindle = {
        preserve_split = true, -- You probably want this
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/
hl.config({
    master = {
        new_status = "master",
    },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#misc
hl.config({
    misc = {
        force_default_wallpaper = -1,   -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = true, -- If true disables the random hyprland logo / anime girl background. :(
    },
})

-------------
---- INPUT ----
-------------
-- https://wiki.hypr.land/Configuring/Basics/Variables/#input
hl.config({
    input = {
        kb_layout          = "latam",
        kb_variant         = "",
        kb_model           = "",
        kb_options         = "",
        kb_rules           = "",

        follow_mouse       = 1,

        sensitivity        = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad           = {
            natural_scroll = true,
        },

        numlock_by_default = true,
    },
})

-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
hl.gesture({ fingers = 3, direction = "up", action = function() hl.exec_cmd("swayosd-client --playerctl play-pause") end })
hl.gesture({ fingers = 3, direction = "down", action = function() hl.exec_cmd("hyprlock") end })
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 4, direction = "up", action = function() hl.exec_cmd("swayosd-client --output-volume 100") end })
hl.gesture({ fingers = 4, direction = "down", action = function() hl.exec_cmd("swayosd-client --output-volume -100") end })
hl.gesture({ fingers = 4, direction = "left", action = function() hl.exec_cmd("swayosd-client --playerctl previous") end })
hl.gesture({ fingers = 4, direction = "right", action = function() hl.exec_cmd("swayosd-client --playerctl next") end })

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})

---------------------
---- KEYBINDINGS ----
---------------------
-- See https://wiki.hypr.land/Configuring/Basics/Binds/
local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- desplazarse con WIN + TAB
hl.bind("ALT + TAB", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("ALT + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }))

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
-- hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("thunar"))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo()) -- dwindle
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("/home/falo/.config/rofi/launchers/type-1/launcher.sh"))

-- abrir, cerrar y reiniciar waybar
hl.bind(mainMod .. " + XF86Launch2", hl.dsp.exec_cmd("pkill waybar && waybar&"))
hl.bind(mainMod .. " + SHIFT + XF86Launch2", hl.dsp.exec_cmd("waybar&"))
hl.bind(mainMod .. " + ALT + XF86Launch2", hl.dsp.exec_cmd("pkill waybar"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "up" }))

-- Nota: "fullscreen" ya no es un dispatcher sin argumentos; el equivalente
-- más cercano en la nueva API es hl.dsp.window.fullscreen (verificar en tu versión).
hl.bind(mainMod .. " + F11", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + S", hl.dsp.focus({ workspace = 17 }))
hl.bind(mainMod .. " + D", hl.dsp.focus({ workspace = 18 }))
hl.bind(mainMod .. " + E", hl.dsp.focus({ workspace = 19 }))
hl.bind(mainMod .. " + W", hl.dsp.focus({ workspace = 20 }))

hl.bind(mainMod .. " + ALT + S", hl.dsp.window.move({ workspace = 17 }))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.window.move({ workspace = 18 }))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.window.move({ workspace = 19 }))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.window.move({ workspace = 20 }))

-- Example special workspace (scratchpad)
-- hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
-- hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- SWAYOSD -----------------
-- Brillo de pantalla
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("swayosd-client --brightness raise"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"),
    { locked = true, repeating = true })

-- Volumen
hl.bind("F7", hl.dsp.exec_cmd("swayosd-client --output-volume raise"), { locked = true, repeating = true })
hl.bind("F6", hl.dsp.exec_cmd("swayosd-client --output-volume lower"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"),
    { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"),
    { locked = true, repeating = true })

-- Multimedia
hl.bind("F9", hl.dsp.exec_cmd("swayosd-client --playerctl play-pause"), { locked = true })
hl.bind("F8", hl.dsp.exec_cmd("swayosd-client --playerctl prev"), { locked = true })
hl.bind("F10", hl.dsp.exec_cmd("swayosd-client --playerctl next"), { locked = true })
-- --------------------------

-- cap de pantalla
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))
-- cap de pantalla se guarda en images
hl.bind("PRINT", hl.dsp.exec_cmd('grim -g "$(slurp)" ~/images/capturas/$(date +%Y-%m-%d_%H-%M-%S).png'))

-- admin de tareas
hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd("kitty -e btop"))

-- bloqueo de pantalla
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
-- menu de apagado
hl.bind(mainMod .. " + F1", hl.dsp.exec_cmd("/home/falo/.config/rofi/powermenu/type-2/powermenu.sh"))
-- para el wifi
-- hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("/home/falo/.config/rofi/rofi-wifi-menu.sh"))

-- para el bluetooth
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("blueman-manager"))

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- y https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example windowrule
-- hl.window_rule({ match = { class = "kitty" }, float = true, center = true, size = {1500, 500} })

-- Ignore maximize requests from apps. You'll probably like this.
-- hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- Fix some dragging issues with XWayland
-- hl.window_rule({ match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false }, no_focus = true })

-- thunar en ventana
hl.window_rule({ match = { class = "zen" }, workspace = "1" })
hl.window_rule({ match = { class = "com.rtosta.zapzap" }, workspace = "20" })

hl.window_rule({
    name      = "thunar",
    match     = { class = "thunar" },

    workspace = "19",
    float     = true,
    center    = true,
    size      = { 1000, 800 },
})

-- hl.window_rule({ match = { class = "thunar" }, float = true })

-- bluetooth
hl.window_rule({ match = { class = ".blueman-manager-wrapped" }, float = true })

-- imagenes
hl.window_rule({
    name   = "imagenes",
    match  = { class = "imv" },

    float  = true,
    center = true,
    size   = { 1600, 900 },
})

-- steam
hl.window_rule({ match = { class = "steam" }, workspace = "10" })
hl.window_rule({ match = { class = "Buckshot Roulette" }, workspace = "9" })      -- hasta q actualicen el windowrule
hl.window_rule({ match = { class = "Hollow Knight Silksong" }, workspace = "9" }) -- hasta q actualicen el windowrule

-- spotify
hl.window_rule({ match = { class = "Spotify" }, workspace = "17" })
-- discord
hl.window_rule({ match = { class = "discord" }, workspace = "18" })

hl.window_rule({ match = { class = "ZapZap" }, workspace = "20" })

-- nmtui bindeado y flotante
hl.bind("SUPER + SHIFT + Q", hl.dsp.exec_cmd('kitty --class "kitty-flotante"'))
hl.window_rule({
    name  = "kittyvolador",
    match = { class = "kitty-flotante" },

    float = true,
    move  = { 15, 700 },
    size  = { 600, 375 },
})

-- nmtui bindeado y flotante
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(
    "env NEWT_COLORS='root=default,default;window=default,default;border=default,default;textbox=default,default;button=black,white;actbutton=white,black;listbox=default,default;actlistbox=default,default;actsellistbox=black,blue;sellistbox=black,white' kitty --class \"nmtui-float\" -o window_padding_width=0 -e nmtui connect"
))
hl.window_rule({
    name   = "menu_wifi",
    match  = { class = "nmtui-float" },

    float  = true,
    center = true,
    size   = { 525, 375 },
})

hl.window_rule({
    name      = "gtk",
    match     = { class = "xdg-desktop-portal-gtk" },

    float     = true,
    move      = { 15, 55 },
    size      = { 700, 500 },
    animation = "popin",
})
