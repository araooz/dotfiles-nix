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
      canTouchEfiVariables = false; 
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;

      efiInstallAsRemovable = true;
      copyKernels = true;

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
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "bluetooth" "video" "audio" "docker" "input"];
  };

##     PROGRAMAS
  programs.git.enable = true;
  programs.firefox.enable = true;
  programs.dconf.enable = true;
  programs.zsh.enable = true;
# hyrprland
  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
  };
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "gtk" ]; 
  };
# spicetify  
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
      ncsVisualizer
    ];
  };
# fish
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting

  #intercambiar lo que hacen TAB y -> 
      bind \t accept-autosuggestion
      bind \e\[C complete
    '';
  };

#--------------------------PAQUETES--------------------------
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
#basicos
    git
    github-cli
    vim 
    wget curl 
    hyprlock hyprpaper rofi wev
    brightnessctl
    os-prober efibootmgr

    glib
#me esta llegando al huevo q no se actualice correctamente
    waybar
#testeo
    tailscale
    docker-compose
#juego

  ];
#------------------------------------------------------------

  environment.shellAliases = {
    nixwasa = "sudo nixos-rebuild switch --flake /home/falo/.config/nix";
    carajoquieroespacio = "sudo nix-env -p /nix/var/nix/profiles/system --delete-generations old && nix-env --delete-generations old && sudo nix-collect-garbage -d && nix-store --optimize";
  };

#------------------------------------------------------------
##     AUDIO
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true; 
  };
  services.tailscale.enable = true;
#brillo
  services.udev.packages = [ pkgs.swayosd ];


##     BLUETOOTH
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

#      THUNAR
  services.gvfs.enable = true; # Montar discos y soporte de papelera
  services.tumbler.enable = true; # Soporte para miniaturas
# YAZI
  environment.variables = {
    EDITOR = "nvim"; # O "nano", "code", "emacs", etc.
  };

##     STEAM
hardware.graphics = {
  enable = true;
  enable32Bit = true;
  extraPackages = with pkgs; [
    rocmPackages.clr.icd
  ];
};
programs.steam = {
  enable = true;
  remotePlay.openFirewall = true; # Opcional: Abre puertos para Remote Play
  dedicatedServer.openFirewall = true; # Opcional: Abre puertos para servidores
  localNetworkGameTransfers.openFirewall = true;
};



fileSystems."/mnt/windows" = {
  device = "/dev/disk/by-uuid/01DC7E10EB7B38D0";
  fsType = "ntfs-3g";
  options = [ "rw" "uid=1000" "gid=100" "umask=0022" "nofail" ];
};


# Además, abre estos puertos UDP específicos que usa L4D2
networking.firewall = {
  enable = true;
  allowedUDPPorts = [ 27015 27016 27031 27036 ];
  allowedTCPPorts = [ 27036 27037 ];
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




