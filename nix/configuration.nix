# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in {
  imports =
    [ ./hardware-configuration.nix ];
#flakes
nix.settings.experimental-features = [ "nix-command" "flakes" ];



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

#---------------------------------------------|
  networking.hostName = "nixos-btw";         #|
  networking.networkmanager.enable = true;   #|
  time.timeZone = "America/Lima";            #|
  i18n.defaultLocale = "es_PE.UTF-8";        #|
  services.xserver.xkb.layout = "latam";     #|
#---------------------------------------------|

# login automático para el usuario falo
  services.getty.autologinUser = "falo";
#hyprland on startup
  environment.loginShellInit = ''
    if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
      exec start-hyprland
    fi
  '';

##     USUARIO  
  users.mutableUsers = true;
  users.users.falo = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "docker"];
  };

##     PROGRAMAS
  programs.git.enable = true;
  programs.firefox.enable = true;
  programs.fish.enable = true;
  programs.dconf.enable = true;
  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
  };
  programs.spicetify = {
    enable = true;
    theme = spicePkgs.themes.hazy;

    enabledExtensions = with spicePkgs.extensions; [
      fullAppDisplay  #Crea una vista de "Reproducción ahora" a pantalla completa
      shuffle         #Reemplaza el algoritmo aleatorio de Spotify por uno realmente aleatorio
      hidePodcasts    
      adblock
      keyboardShortcut
    ];

    enabledCustomApps = with spicePkgs.apps; [
      marketplace
    ];
  };

#--------------------------PAQUETES--------------------------
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
#basicos
    git
    github-cli
    vim 
    wget curl git wev
    hyprlock hyprpaper waybar rofi
    brightnessctl
    os-prober efibootmgr

    glib
#testeo
    tailscale
    docker-compose
  ];
#------------------------------------------------------------



##     AUDIO
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true; 
  };
  services.tailscale.enable = true;


##     BLUETOOTH
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

#para thunar
  services.gvfs.enable = true; # Montar discos y soporte de papelera
  services.tumbler.enable = true; # Soporte para miniaturas


##     STEAM
hardware.graphics = {
  enable = true;
  enable32Bit = true;
};
programs.steam = {
  enable = true;
  remotePlay.openFirewall = true; # Opcional: Abre puertos para Remote Play
  dedicatedServer.openFirewall = true; # Opcional: Abre puertos para servidores
};

##    GRAFICA
services.xserver.videoDrivers = ["amdgpu" ];

##    DOCKER
#virtualisation.docker.enableNvidia = true;
virtualisation.docker.enable = true;

##     FUENTES
  fonts.fontconfig.enable = true;
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.ubuntu
    nerd-fonts.ubuntu-mono
    font-awesome
#para instalar la fuente q permite ver los iconos del rofi powermenu debo descargarla del repo https://github.com/adi1090x/rofi/blob/master/fonts/Icomoon-Feather.ttf y pegarla en ~/.local/share/fonts/
    terminus_font
  ];








#para que nixos pueda ejecutar binarios externos (mason)
  programs.nix-ld.enable = true;




#NO TOCAR
  nix.settings.auto-optimise-store = true;
  system.stateVersion = "25.11";
}




