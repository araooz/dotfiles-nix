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


  home.packages = with pkgs; [
    kitty
    neovim
    tree
    fastfetch
    btop
    unzip
    

    inputs.zen-browser.packages."${pkgs.system}".default
    zapzap
#multimedia
    blueman bluez 
    pavucontrol playerctl pamixer
    imv gimp
    grim slurp 
    easyeffects
#portapapeles
    wl-clipboard 
    wofi
    cliphist
#thunar 
    thunar
    thunar-volman
    thunar-archive-plugin
    tumbler
#explorador de archivos
    ranger
    yazi

#desarrollo
    gcc gnumake
    python3 pyright
    nodejs
    nodePackages.intelephense
    typescript-language-server # (ts_ls)
    vscode-langservers-extracted # (eslint)
    ripgrep     #para nvim telescope
    fd          #para nvim telescope
    jdk21   #JDK para java
    maven 

#apps
    zoom-us
    discord
    vscode
    antigravity-fhs
    obsidian
    postman

    jetbrains.idea
    affine

#terriblemente estetica
    bibata-cursors
#testeo
    jq


    armagetronad
  ];


#-----------------------
home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };


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
    # Te sugiero usar los iconos de Flat Remix para que combinen con el tema
    iconTheme = {
      package = pkgs.flat-remix-icon-theme;
      name = "Flat-Remix-Blue-Dark";
    };
  };

#-----------------------

  home.stateVersion = "25.11"; 
  programs.home-manager.enable = true;
}
