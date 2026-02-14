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
    github-cli
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

#apps
    zoom-us
    google-chrome
    discord
    vscode

#terriblemente estetica
    bibata-cursors
    kdePackages.breeze
    kdePackages.breeze-icons
  ];

  # Gestión de archivos de configuración (Dotfiles)
  # Ejemplo: Home Manager puede crear archivos en ~/.config automáticamente
  /*
  xdg.configFile."kitty/kitty.conf".text = ''
    font_family JetBrainsMono Nerd Font
    font_size 12.0
  '';
  */

  # Configuración de programas vía Home Manager
  programs.git = {
    enable = true;
    userName = "araooz";
    userEmail = "araozfali@gmail.com";
  };





  home.stateVersion = "25.11"; 
  programs.home-manager.enable = true;
}
