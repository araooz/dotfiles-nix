{ config, pkgs, inputs,  ... }:

{
  home.username = "falo";
  home.homeDirectory = "/home/falo";

  home.sessionVariables = {
    TERMINAL = "kitty";

    NIXOS_OZONE_WL = "1"; # Fuerza a apps de Electron (como ZapZap) a usar Wayland
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
                                                                                           #esto comentado porq KDE ya gestiona sus cosos
    GTK_THEME = "Adwaita-Dark"; 
    XCURSOR_THEME = "Breeze_Snow";
    XCURSOR_SIZE = "24"; 
    HYPRCURSOR_SIZE = "24";
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
    obsidian
    postman

    jetbrains.idea
    affine

#terriblemente estetica
    bibata-cursors
    kdePackages.breeze
    kdePackages.breeze-icons
#testeo
    jq


    armagetronad
  ];



  home.stateVersion = "25.11"; 
  programs.home-manager.enable = true;
}
