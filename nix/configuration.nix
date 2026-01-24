# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in {
  imports =
    [ ./hardware-configuration.nix ];
#flakes
nix.settings.experimental-features = [ "nix-command" "flakes" ];
# Use the systemd-boot EFI boot loader.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true; 
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
      gfxmodeEfi = "1920x1080";
      theme = pkgs.fetchFromGitHub {
        owner = "AllJavi";
        repo = "tartarus-grub";
        rev = "b116360a2a0991062a4d728cb005dfd309fbb82a";
        sha256 = "sha256-/Pzr0R3zzOXUi2pAl8Lvg6aHTiwXTIrxQ1vscbEK/kU=";
      } + "/tartarus";
    };
    systemd-boot.enable = false; 
  };


  networking.hostName = "nixos-btw";
  networking.networkmanager.enable = true;
  time.timeZone = "America/Lima";
  i18n.defaultLocale = "es_PE.UTF-8";
  

  services.xserver.xkb.layout = "latam"; #us

# Habilitar el login automático para el usuario falo
  services.getty.autologinUser = "falo";

#y ejecutar hyprland de una
  environment.loginShellInit = ''
    if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
      exec start-hyprland
    fi
  '';
# presunto fix para lo de hyprland que se cierran las apps apenas las abro
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Fuerza a apps de Electron (como ZapZap) a usar Wayland
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    # Fix para temas oscuros y Dolphin
    GTK_THEME = "Adwaita:dark";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_QPA_PLATFORM = "wayland";
  };


  users.mutableUsers = true;
  users.users.falo = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio"];
    packages = with pkgs; [
      tree
      git
      kitty
      neovim
    ];
  };

  programs.firefox.enable = true;
  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
  };
  programs.git.enable = true;
  programs.spicetify = {
    enable = true;
    colorScheme = "Rigel";
    theme = spicePkgs.themes.text;
    enabledExtensions = with spicePkgs.extensions; [
      fullAppDisplay  #Crea una vista de "Reproducción ahora" a pantalla completa
      shuffle         #Reemplaza el algoritmo de reproducción aleatoria de Spotify por uno realmente aleatorio
      hidePodcasts    
      adblock
      keyboardShortcut
    ];
  };
  # You can use https://search.nixos.org/ to find more packages (and options).
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
# entorno
    git
    github-cli
    neovim
    kitty
    hyprlock
    hyprpaper
    waybar
    rofi
    zapzap
    fastfetch
    btop

    vim
    wget
    curl
    terminus_font
    easyeffects
    os-prober
    unzip
    efibootmgr
    inputs.zen-browser.packages."${pkgs.system}".default
    wev
#audio y brillo
    pavucontrol
    playerctl
    blueman
    bluez
    pamixer
    brightnessctl
    glib
#Dolphin
    ranger # FCK DOLPHIN RANGER LO ES TODO (recien lo voy a probar)

    kdePackages.dolphin
    kdePackages.qtwayland        # Soporte nativo para Wayland
    kdePackages.qtsvg            # Para que los iconos se vean bien
    kdePackages.kio-extras       # Miniaturas y funciones extra
    adwaita-qt                   # Tema para que apps Qt parezcan de GNOME/Modernas (opcional)
    libsForQt5.qtstyleplugin-kvantum # Si quieres temas muy personalizados
    libsForQt5.qt5ct
    kdePackages.qt6ct
    adwaita-qt6
#imagenes y capturas
    grim
    slurp
    imv
    wl-clipboard
    gimp
# lenguajes
    gcc
    gnumake
    python3
    pyright
    nodejs
    nodePackages.intelephense
    typescript-language-server # (ts_ls)
    vscode-langservers-extracted # (eslint)
    ripgrep     #para nvim telescope
    fd          #para nvim telescope
#apps
    zoom-us
    steam
    google-chrome
    bibata-cursors
    discord
    spicetify-cli
  ];

#audio
  services.pipewire = {
    enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true; 
  };
# ventilador
  services.thermald.enable = true;
#bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
#lo de dolphin
#xdg.portal = {
#  enable = true;
#  extraPortals = [ 
#    pkgs.xdg-desktop-portal-hyprland
#    pkgs.xdg-desktop-portal-gtk 
#  ];
#  config.common.default = "*";
#};
#steam
hardware.graphics = {
  enable = true;
  enable32Bit = true; # Muy importante para Steam
};

programs.steam = {
  enable = true;
  remotePlay.openFirewall = true; # Opcional: Abre puertos para Remote Play
  dedicatedServer.openFirewall = true; # Opcional: Abre puertos para servidores
};

services.xserver.videoDrivers = [ "nvidia" ];
#hardware.nvidia.open = false; # Depende de tu modelo de tarjeta        ya lo uso despues


#fuentes
  fonts.fontconfig.enable = true;
  fonts.packages = with pkgs; [
  #  (nerdfonts.override { fonts = [ "JetBrainsMono" "Ubuntu" "UbuntuMono" ]; })
  #  font-awesome
#para instalar la fuente q permite ver los iconos del rofi powermenu debo descargarla del repo https://github.com/adi1090x/rofi/blob/master/fonts/Icomoon-Feather.ttf y pegarla en ~/.local/share/fonts/
  ];








# 1. Forzar que el kernel use los módulos de NVIDIA correctamente                           SOLUCION DESESPERADA YA ME QUIERO IR A MI CASA PERO NICAGANDO HASTA QUE ESTE LISTO EL HYPRLAND
  boot.kernelParams = [ "nvidia_drm.modeset=1" "nvidia_drm.fbdev=1" ];

  # 2. Configuración específica de NVIDIA
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false; # Cambia a true si quieres probar los drivers abiertos, pero false es más estable para la 3050
    nvidiaSettings = true;
    
    # IMPORTANTE: Al ser una laptop, necesitas activar el modo híbrido (Prime)
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      # Necesitas confirmar estos IDs con 'lspci', pero suelen ser estos:
      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:6:0:0"; # Ajusta según tu hardware-configuration.nix
    };
  };

  # 3. Variables de entorno para Hyprland
  environment.sessionVariables = {
  #  LIBVA_DRIVER_NAME = "nvidia";
  #  __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  #  GBM_BACKEND = "nvidia-drm";
  };



#para que nixos pueda ejecutar binarios externos (mason)
  programs.nix-ld.enable = true;

  nix.settings.auto-optimise-store = true;
  system.stateVersion = "25.11";
}




