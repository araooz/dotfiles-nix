-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
local window_rule = hl.window_rule

-- browser, whatsapp
window_rule({ match = { class = "zen" }, workspace = "1" })
window_rule({ match = { class = "ZapZap" }, workspace = "20" })
-- steam, spotify, discord
window_rule({ match = { class = "steam" }, workspace = "10" })
window_rule({ match = { class = "Spotify" }, workspace = "17" })
window_rule({ match = { class = "discord" }, workspace = "18" })

-- multimetida
window_rule({
    name   = "imagenes",
    match  = { class = "imv" },
    float  = true,
    center = true,
    size   = { 1600, 900 },
})
window_rule({
    name   = "videos",
    match  = { class = "mpv" },
    float  = true,
    center = true,
    size   = { 1600, 900 },
})
-- varios
window_rule({
    name      = "menu_wifi",
    match     = { class = "nmtui-float" },
    float     = true,
    center    = true,
    size      = { 525, 375 },
    animation = "popin",
})
window_rule({
    name      = "gtk",
    match     = { class = "xdg-desktop-portal-gtk" },
    float     = true,
    move      = { 15, 55 },
    size      = { 700, 500 },
    animation = "popin",
})
window_rule({
    name        = "kittyvolador",
    match       = { class = "kitty-flotante" },
    float       = true,
    move        = { 15, 700 },
    size        = { 600, 375 },
    animation   = "popin",
    border_size = 0,
    pin         = true,
})
window_rule({
    name      = "fileManager",
    match     = { class = "thunar" },
    workspace = "19",
    float     = true,
    center    = true,
    size      = { 1000, 800 },
})
window_rule({
    name  = "bluetooth",
    match = { class = "bluetui" },
    float = true,
    size  = { 800, 400 },
    move  = { 1100, 630 },
})
