# ----------------- theme.nix ----------------- #
# UNICA fuente de colores y fuente del sistema.
# Cambia algo aqui, haz rebuild y se regeneran:
#   hypr/colors.conf        (hyprlock)
#   hypr/stuff/colors.lua   (bordes de Hyprland)
#   kitty/theme.conf
#   rofi/theme.rasi         (launcher, powermenu, wifi, portapapeles)
#   waybar/theme.css
#   nvim/lua/theme_colors.lua
#   quickshell/Colors.qml   (panel wifi + notificaciones)
#   starship.toml           (colores del prompt)
# Estos archivos son symlinks al nix store: NO los edites a mano.
{ config, pkgs, lib, ... }:

let
  # colores sin "#" para poder usarlos en cualquier formato
  c = {
    bg        = "000000";
    bgAlt     = "0d0d0d";
    surface   = "1a1a1a";
    overlay   = "2e2e2e";
    muted     = "6c6c6c";
    fg        = "e6e6e6";

    accent    = "e0afff"; # morado
    accentDim = "a77bca";

    red       = "ff0000";
    green     = "00ff00";
    yellow    = "ffd479";
    blue      = "8ab4ff";
    cyan      = "8be9fd";
  };

  font = {
    name = "JetBrainsMono Nerd Font Propo";
    # kitty necesita la variante Mono (iconos de ancho fijo), es la misma letra
    mono = "JetBrainsMono Nerd Font Mono";
    package = pkgs.nerd-fonts.jetbrains-mono;
  };
in
{
  # ---------------- fuente para todo ----------------
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ font.name ];
      serif     = [ font.name ];
      monospace = [ font.mono ];
    };
  };
  gtk.font = {
    inherit (font) name package;
    size = 10;
  };

  # ---------------- archivos generados ----------------
  xdg.configFile."hypr/colors.conf".text = ''
    $font        = ${font.name}
    $fontMono    = ${font.mono}
    $bg          = rgb(${c.bg})
    $bgAlpha     = ${c.bg}
    $fg          = rgb(${c.fg})
    $fgAlpha     = ${c.fg}
    $muted       = rgb(${c.muted})
    $accent      = rgb(${c.accent})
    $accentAlpha = ${c.accent}
    $red         = rgb(${c.red})
    $green       = rgb(${c.green})
    $yellow      = rgb(${c.yellow})
    $blue        = rgb(${c.blue})
  '';

  xdg.configFile."hypr/stuff/colors.lua".text = ''
    return {
    	bg = "${c.bg}",
    	fg = "${c.fg}",
    	accent = "${c.accent}",
    	accentDim = "${c.accentDim}",
    	muted = "${c.muted}",
    }
  '';

  xdg.configFile."kitty/theme.conf".text = ''
    font_family             ${font.mono}
    foreground              #${c.fg}
    background              #${c.bg}
    selection_foreground    #${c.bg}
    selection_background    #${c.accent}
    url_color               #${c.accent}
    cursor                  #${c.accent}
    cursor_text_color       #${c.bg}

    active_tab_foreground   #${c.bg}
    active_tab_background   #${c.accent}
    inactive_tab_foreground #${c.muted}
    inactive_tab_background #${c.surface}
    tab_bar_background      #${c.bg}

    # negro, rojo, verde, amarillo, azul, magenta, cian, blanco
    color0  #${c.surface}
    color8  #${c.muted}
    color1  #${c.red}
    color9  #${c.red}
    color2  #${c.green}
    color10 #${c.green}
    color3  #${c.yellow}
    color11 #${c.yellow}
    color4  #${c.blue}
    color12 #${c.blue}
    color5  #${c.accentDim}
    color13 #${c.accent}
    color6  #${c.cyan}
    color14 #${c.cyan}
    color7  #${c.fg}
    color15 #ffffff
  '';

  xdg.configFile."rofi/theme.rasi".text = ''
    * {
        font:           "${font.name} 11";
        background:     #${c.bg}FF;
        background-alt: #${c.surface}FF;
        foreground:     #${c.fg}FF;
        selected:       #${c.accent}FF;
        active:         #${c.accentDim}FF;
        urgent:         #${c.red}FF;
    }
  '';

  xdg.configFile."waybar/theme.css".text = ''
    @define-color bg      #${c.bg};
    @define-color surface #${c.surface};
    @define-color overlay #${c.overlay};
    @define-color muted   #${c.muted};
    @define-color fg      #${c.fg};
    @define-color accent  #${c.accent};
    @define-color red     #${c.red};
    @define-color green   #${c.green};

    * {
        font-family: "${font.name}";
    }
  '';

  xdg.configFile."nvim/lua/theme_colors.lua".text = ''
    return {
    	bg = "#${c.bg}",
    	bgAlt = "#${c.bgAlt}",
    	surface = "#${c.surface}",
    	overlay = "#${c.overlay}",
    	muted = "#${c.muted}",
    	fg = "#${c.fg}",
    	accent = "#${c.accent}",
    	accentDim = "#${c.accentDim}",
    }
  '';

  # ---------------- Qt: usa la paleta del tema GTK ----------------
  # "gtk3" es el plugin nativo de Qt (el valor "gtk" esta deprecado)
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

  # ---------------- starship ----------------
  programs.starship.settings = {
    palette = "theme";
    palettes.theme = {
      accent    = "#${c.accent}";
      accentDim = "#${c.accentDim}";
      muted     = "#${c.muted}";
      fg        = "#${c.fg}";
      red       = "#${c.red}";
      green     = "#${c.green}";
      yellow    = "#${c.yellow}";
    };

    format = "$directory$git_branch$git_status$nix_shell$cmd_duration$line_break$character";
    right_format = "$c$python$nodejs$rust$java";

    directory = {
      style = "bold accent";
      truncation_length = 3;
      truncation_symbol = "…/";
      read_only = " ";
      read_only_style = "red";
    };
    git_branch = {
      format = "[$symbol$branch]($style) ";
      symbol = " ";
      style = "accentDim";
    };
    git_status = {
      format = "([$all_status$ahead_behind]($style) )";
      style = "yellow";
    };
    nix_shell = {
      format = "[$symbol$name]($style) ";
      symbol = " ";
      style = "accentDim";
      heuristic = true;
    };
    cmd_duration = {
      format = "[ $duration]($style) ";
      style = "muted";
      min_time = 2000;
    };
    character = {
      success_symbol = "[❯](bold accent)";
      error_symbol   = "[❯](bold red)";
      vimcmd_symbol  = "[❮](bold green)";
    };
    c      = { format = "[$symbol$version]($style) "; style = "muted"; symbol = " "; };
    python = { format = "[$symbol$version]($style) "; style = "muted"; symbol = " "; };
    nodejs = { format = "[$symbol$version]($style) "; style = "muted"; symbol = " "; };
    rust   = { format = "[$symbol$version]($style) "; style = "muted"; symbol = " "; };
    java   = { format = "[$symbol$version]($style) "; style = "muted"; symbol = " "; };
  };

  # ---------------- panel lateral (quickshell) ----------------
  xdg.configFile."quickshell/Colors.qml".text = ''
    pragma Singleton

    import QtQuick
    import Quickshell

    // generado por nix/theme.nix
    Singleton {
    	readonly property string font: "${font.name}"
    	readonly property color bg: "#${c.bg}"
    	readonly property color bgAlt: "#${c.bgAlt}"
    	readonly property color surface: "#${c.surface}"
    	readonly property color overlay: "#${c.overlay}"
    	readonly property color muted: "#${c.muted}"
    	readonly property color fg: "#${c.fg}"
    	readonly property color accent: "#${c.accent}"
    	readonly property color accentDim: "#${c.accentDim}"
    	readonly property color red: "#${c.red}"
    	readonly property color green: "#${c.green}"
    	readonly property color yellow: "#${c.yellow}"
    }
  '';
}
