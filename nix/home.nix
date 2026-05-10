{ config, pkgs, inputs,  ... }:

{
  home.username = "falo";
  home.homeDirectory = "/home/falo";

  home.sessionVariables = {
    TERMINAL = "kitty";

    NIXOS_OZONE_WL = "1"; # Fuerza a apps de Electron (como ZapZap) a usar Wayland
    GTK_USE_PORTAL = 1;
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };

# PROGRAMAS
  home.packages = with pkgs; [
# bare minimum
    kitty
    tree
    fastfetch
    btop
    inputs.zen-browser.packages."${pkgs.system}".default
#multimedia
    blueman bluez 
    pavucontrol playerctl pamixer
    imv gimp
    grim slurp 
    easyeffects
    mpv
#portapapeles
    wl-clipboard 
    #wofi
    cliphist
#thunar 
    thunar
    thunar-volman
    thunar-archive-plugin
    tumbler
# lenguajes, dependencias y esas weas
    gcc gnumake
    (python3.withPackages (ps: with ps; [
      matplotlib
      numpy
      # Puedes agregar más aquí, como pandas o scikit-learn
    ]))
    pyright
    nodejs
    pnpm
    intelephense
    typescript-language-server # (ts_ls)
    vscode-langservers-extracted # (eslint)
    ripgrep     #para nvim telescope
    fd          #para nvim telescope
    jdk21   #JDK para java
    maven 
    graphviz-nox  # dots para compi
    jq

#code
    vscode-fhs
    inputs.antigravity.packages.${pkgs.system}.default
    code-cursor
    postman

    jetbrains.idea
    jetbrains.clion
    jetbrains.webstorm
# utilidades
    unzip
    zip
#apps
    localsend
    zoom-us
    discord
    obsidian
    affine  
    zapzap
    onlyoffice-desktopeditors
    davinci-resolve
#terriblemente estetica
    bibata-cursors
#juego
    armagetronad
#testeo

  ];

# ------------------------------ YAZI
programs.yazi = {
  enable = true;
  settings = {
    opener = {
      zen = [
        { run = ''zen-browser "$@"''; block = false; desc = "Zen Browser"; }
      ];
    };
    open = {
      prepend_rules = [
        { name = "*.pdf"; use = "zen"; }
      ];
    };
  };
};
# -------------------------------- NEOVIM
programs.neovim = {
  enable = true;
  extraLuaConfig = ''
    require("config.options")
    require("config.keybinds")
    require("config.lazy")

    vim.cmd([[
      cnoreabbrev W  w
      cnoreabbrev Q  q
      cnoreabbrev Wq wq
      cnoreabbrev WQ wq
      cnoreabbrev Qa qa
    ]])
  '';
};
# ----------para davinci-resolve y que se guarden en una carpeta especifica
  xdg.userDirs = {
    enable = true;
    createDirectories = false;    #para que no me cree las putas carpetas tipo windows en el ~/ 

    # Redirigimos TODO a tu carpeta centralizada
    desktop = "${config.home.homeDirectory}/cosasquenoquieroqueocupensupropiacarpeta/Desktop";
    documents = "${config.home.homeDirectory}/cosasquenoquieroqueocupensupropiacarpeta/Documents";
    download = "${config.home.homeDirectory}/downloads";
    music = "${config.home.homeDirectory}/cosasquenoquieroqueocupensupropiacarpeta/Music";
    pictures = "${config.home.homeDirectory}/cosasquenoquieroqueocupensupropiacarpeta/Pictures";
    publicShare = "${config.home.homeDirectory}/cosasquenoquieroqueocupensupropiacarpeta/Public";
    templates = "${config.home.homeDirectory}/cosasquenoquieroqueocupensupropiacarpeta/Templates";
    videos = "${config.home.homeDirectory}/cosasquenoquieroqueocupensupropiacarpeta/Videos";
  };

#-----------------------
home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  gtk.gtk4.theme = config.gtk.theme;

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.flat-remix-gtk;
      name = "Flat-Remix-GTK-Grey-Darkest";
    };
    iconTheme = {
      package = pkgs.flat-remix-icon-theme;
      name = "Flat-Remix-Blue-Dark";
    };
  };
#-----------------------
# Configuración de aplicaciones por defecto
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/jpeg" = [ "imv.desktop" ];
      "image/png" = [ "imv.desktop" ];
      "image/gif" = [ "imv.desktop" ];
      "image/webp" = [ "imv.desktop" ];
      "image/bmp" = [ "imv.desktop" ];
      "image/tiff" = [ "imv.desktop" ];
      "image/svg+xml" = [ "imv.desktop" ];
      "application/pdf" = [ "zen.desktop" ];
      "video/mp4" = [ "mpv.desktop" ];
      "video/quicktime" = [ "mpv.desktop" ]; # para archivos .mov
      "video/x-matroska" = [ "mpv.desktop" ]; # para archivos .mkv
      "video/webm" = [ "mpv.desktop" ];
    };
  };
#-----------------------
#BRILLO
  services.swayosd.enable = true;






#-----------------------
  home.stateVersion = "25.11"; 
  programs.home-manager.enable = true;
}
