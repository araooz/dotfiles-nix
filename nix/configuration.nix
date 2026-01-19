# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:
#zen
let
  zen-browser = import (builtins.fetchTarball "https://github.com/youwen5/zen-browser-flake/archive/master.tar.gz") { inherit pkgs; };
in
{
  imports =
    [ ./hardware-configuration.nix ];

# Use the systemd-boot EFI boot loader.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true; # Cambiado a false para proteger a Arch después
  #    efiSysMountPoint = "/boot";
    };
  #  grub = {
  #    enable = true;
  #    device = "nodev";
  #    efiSupport = true;
  #    useOSProber = true;
  #    gfxmodeEfi = "1920x1080";
  #    theme = pkgs.fetchFromGitHub {
  #      owner = "AllJavi";
  #      repo = "tartarus-grub";
  #      rev = "b116360a2a0991062a4d728cb005dfd309fbb82a";
  #      sha256 = "sha256-/Pzr0R3zzOXUi2pAl8Lvg6aHTiwXTIrxQ1vscbEK/kU=";
  #    } + "/tartarus";
  #  };
    systemd-boot.enable = true; # Ahora está DENTRO del bloque correcto
  };


  networking.hostName = "nixos-btw";
  networking.networkmanager.enable = true;
  time.timeZone = "America/Lima";
  i18n.defaultLocale = "es_PE.UTF-8";
  
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  #console = {
  #  font = "ter-v32b";
  #  keyMap = "la-latin1"; #us
  #   useXkbConfig = true; # use xkb.options in tty.
  #};
 

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  services.xserver.xkb.layout = "latam"; #us

# Habilitar el login automático para el usuario falo
  services.getty.autologinUser = "falo";

#y ejecutar hyprland de una
  environment.loginShellInit = ''
    if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
      exec Hyprland
    fi
  '';
# presunto fix para lo de hyprland que se cierran las apps apenas las abro
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Fuerza a apps de Electron (como ZapZap) a usar Wayland
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
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
  programs.hyprland.enable = true;
  programs.git.enable = true;



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
    zen-browser.default
    wev
#audio y brillo
    pavucontrol
    playerctl
    blueman
    bluez
    pamixer
    brightnessctl
    glib
#dolphin
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
  ];

#audio
  services.pipewire = {
    enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true; 
  };
#bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
#lo de dolphin
xdg.portal = {
  enable = true;
  extraPortals = [ 
    pkgs.xdg-desktop-portal-hyprland
    pkgs.xdg-desktop-portal-gtk 
  ];
  config.common.default = "*";
};
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
hardware.nvidia.open = false; # Depende de tu modelo de tarjeta



#fuentes
  fonts.fontconfig.enable = true;
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.ubuntu-mono
    font-awesome
#para instalar la fuente q permite ver los iconos del rofi powermenu debo descargarla del repo https://github.com/adi1090x/rofi/blob/master/fonts/Icomoon-Feather.ttf y pegarla en ~/.local/share/fonts/
  ];


# modo oscuro
#  qt.enable = true;
#  qt.platformTheme = "qt5ct";

# Esto ayuda a que las apps GTK3/4 sepan que prefieres el modo oscuro
#  environment.sessionVariables = {
#    GTK_THEME = "Adwaita:dark";
#    ADW_DISABLE_PORTAL = "1";
#    # Forzar que Qt use la configuración que acabas de guardar
#    QT_QPA_PLATFORMTHEME = "qt6ct"; 
#    # Opcional: Ayuda a que Dolphin se vea mejor en Wayland
#    QT_QPA_PLATFORM = "wayland";
#  };

#para que nixos pueda ejecutar binarios externos (mason)
  programs.nix-ld.enable = true;



  nix.settings.auto-optimise-store = true;



  system.stateVersion = "25.11";
}




