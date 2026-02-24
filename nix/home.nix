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

    GTK_THEME = "Adwaita-Dark"; 
    XCURSOR_THEME = "Breeze_Snow";
    XCURSOR_SIZE = "24"; 
    HYPRCURSOR_SIZE = "24";
  };


  # Paquetes específicos del usuario (puedes moverlos desde configuration.nix aquí)
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
    imv wl-clipboard gimp
    grim slurp 
    easyeffects
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
    google-chrome
    discord
    vscode
    obsidian
    postman

    inputs.antigravity.packages."${pkgs.system}".default
#terriblemente estetica
    bibata-cursors
    kdePackages.breeze
    kdePackages.breeze-icons
#testeo
    jetbrains.idea-oss
  ];

  programs.waybar = {
    enable = true;
    systemd.enable = true; 
    systemd.target = "hyprland-session.target"; 
  };



  gtk = {
    enable = true;
    iconTheme = {
      name = "breeze-dark";
      package = pkgs.kdePackages.breeze-icons;
    };
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };

  home.stateVersion = "25.11"; 
  programs.home-manager.enable = true;
}
