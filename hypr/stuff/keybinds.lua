-- See https://wiki.hypr.land/Configuring/Basics/Binds/
local bind = hl.bind
local gesture = hl.gesture

local mainMod = "SUPER" -- Sets "Windows" key as main modifier


----------------------------------------- Navegacion basica  ------------------------------------------
bind("ALT + TAB", hl.dsp.focus({ workspace = "e+1" }), { repeating = true })
bind("ALT + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }), { repeating = true })

bind(mainMod .. " + Q", hl.dsp.exec_cmd("kitty"))
bind(mainMod .. " + C", hl.dsp.window.close())
bind(mainMod .. " + M", hl.dsp.exit())
bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
bind(mainMod .. " + P", hl.dsp.window.pseudo()) -- dwindle
bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("/home/falo/.config/rofi/launchers/type-1/launcher.sh"))

-------------------------------------------------- WAYBAR -----------------------------------------------
bind(mainMod .. " + XF86Launch2", hl.dsp.exec_cmd("pkill waybar && waybar&"))
bind(mainMod .. " + SHIFT + XF86Launch2", hl.dsp.exec_cmd("waybar&"))
bind(mainMod .. " + ALT + XF86Launch2", hl.dsp.exec_cmd("pkill waybar"))

----------------------------------------------- Windows -------------------------------------------------
bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
bind(mainMod .. " + h", hl.dsp.focus({ direction = "right" }))
bind(mainMod .. " + j", hl.dsp.focus({ direction = "up" }))
bind(mainMod .. " + F11", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))

-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
bind(mainMod .. " + S", hl.dsp.focus({ workspace = 17 }))
bind(mainMod .. " + D", hl.dsp.focus({ workspace = 18 }))
bind(mainMod .. " + E", hl.dsp.focus({ workspace = 19 }))
bind(mainMod .. " + W", hl.dsp.focus({ workspace = 20 }))
bind(mainMod .. " +  ALT +  S", hl.dsp.window.move({ workspace = 17 }))
bind(mainMod .. " + SHIFT + D", hl.dsp.window.move({ workspace = 18 }))
bind(mainMod .. " + SHIFT + E", hl.dsp.window.move({ workspace = 19 }))
bind(mainMod .. " + SHIFT + W", hl.dsp.window.move({ workspace = 20 }))
-- Example special workspace (scratchpad)
bind(mainMod .. "+ Z", hl.dsp.workspace.toggle_special("magic"))


---------------------------------------------- TRACKPAD ----------------------------------------------------
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
gesture({ fingers = 3, direction = "up", action = function() hl.exec_cmd("swayosd-client --playerctl play-pause") end })
gesture({ fingers = 3, direction = "down", action = function() hl.exec_cmd("hyprlock") end })
gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
gesture({ fingers = 4, direction = "up", action = function() hl.exec_cmd("swayosd-client --output-volume 100") end })
gesture({ fingers = 4, direction = "down", action = function() hl.exec_cmd("swayosd-client --output-volume -100") end })
gesture({ fingers = 4, direction = "left", action = function() hl.exec_cmd("swayosd-client --playerctl previous") end })
gesture({ fingers = 4, direction = "right", action = function() hl.exec_cmd("swayosd-client --playerctl next") end })


---------------------------------------------- MOUSE ----------------------------------------------------
bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

----------------------------------------------- SWAYOSD -----------------------------------------------
bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("swayosd-client --brightness raise"), { locked = true, repeating = true })
bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"),
    { locked = true, repeating = true })
-- Volumen
bind("F7", hl.dsp.exec_cmd("swayosd-client --output-volume raise"), { locked = true, repeating = true })
bind("F6", hl.dsp.exec_cmd("swayosd-client --output-volume lower"), { locked = true, repeating = true })
bind("XF86AudioMute ", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"),
    { locked = true, repeating = true })
bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"),
    { locked = true, repeating = true })
bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"),
    { locked = true, repeating = true })
-- Multimedia
bind("F9", hl.dsp.exec_cmd("swayosd-client --playerctl play-pause"), { locked = true })
bind("F8", hl.dsp.exec_cmd("swayosd-client --playerctl prev"), { locked = true })
bind("F10", hl.dsp.exec_cmd("swayosd-client --playerctl next"), { locked = true })

----------------------------------------- VARIOS -----------------------------------------------------
-- cap de pantalla
bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))
bind("PRINT", hl.dsp.exec_cmd('grim -g "$(slurp)" ~/images/capturas/$(date +%Y-%m-%d_%H-%M-%S).png'))
-- admin de tareas
bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd("kitty -e btop"))
-- bloqueo de pantalla
bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
-- menu de apagado
bind(" F1", hl.dsp.exec_cmd("/home/falo/.config/rofi/powermenu/type-2/powermenu.sh"))
-- bluetooth
bind(mainMod .. " + B", hl.dsp.exec_cmd("kitty --class \"bluetui\" -e bluetui"))
-- nmtui bindeado y flotante
bind("SUPER + SHIFT + Q", hl.dsp.exec_cmd('kitty --class "kitty-flotante"'))
-- nmtui bindeado y flotante
bind(mainMod .. " + A",
    hl.dsp.exec_cmd(
        "env NEWT_COLORS='root=default,default;window=default,default;border=default,default;textbox=default,default;button=black,white;actbutton=white,black;listbox=default,default;actlistbox=default,default;actsellistbox=black,blue;sellistbox=black,white' kitty --class \"nmtui-float\" -o window_padding_width=0 -e nmtui connect"))
-- Atajo de teclado para abrir el historial del portapapeles
bind("SUPER + SHIFT + C", hl.dsp.exec_cmd(
    'cliphist list | rofi -dmenu -display-columns 2 -p "busca papaish" -theme /home/falo/.config/rofi/launchers/type-1/style-5.rasi | cliphist decode | wl-copy'
))


bind(" XF86Launch2 ", hl.dsp.exec_cmd("spotify"))
bind(" XF86Launch2 ", hl.dsp.focus({ workspace = 17 }))
bind(" XF86Calculator ", hl.dsp.focus({ workspace = 3 }))
bind(" XF86Calculator ", hl.dsp.exec_cmd("kitty -e yazi"))



-----------------------------------------------------------------------------------------------------






---
