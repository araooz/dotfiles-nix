# ----------------- configuration.nix ----------------- #
{ config, lib, pkgs, inputs, ... }:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in {
  imports =
    [ ./hardware-configuration.nix ];
#flakes
nix.settings.experimental-features = [ "nix-command" "flakes" ];

# Garbage collection automático
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };



  boot.loader = {
    efi = {
      canTouchEfiVariables = true; 
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;

      useOSProber =             false;
      efiInstallAsRemovable =   false;
      copyKernels =             false;

      gfxmodeEfi = "1920x1080";

      theme = pkgs.stdenv.mkDerivation {
        pname = "marathon-grub-theme";
        version = "main";
  
        src = pkgs.fetchFromGitHub {
          owner = "Woysful";
          repo = "Marathon-Grub-Themes";
          rev = "main"; # Rama objetivo
          hash = "sha256-WcPuFoyIESUwSmOa6wK6+3p7O13l+eziHU4jIEIY9Pw="; 
        };
  
        installPhase = ''
          mkdir -p $out
          cp -r Marathon-NewCascadia/* $out/
          
          # NixOS requiere obligatoriamente que el archivo se llame "theme.txt"
          mv $out/theme_900p-1080p.txt $out/theme.txt
        '';
    };
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
    extraGroups = [ "wheel" "networkmanager" "bluetooth" "video" "audio" "docker" "input" "libvirtd" ];
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
    config = {
      common.default = [ "gtk" ];
      hyprland = {
        default = [ "gtk" "hyprland" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
      };
    };
  };
# spicetify  
  programs.spicetify = {
    enable = true;
    theme = spicePkgs.themes.hazy;
    enabledExtensions = with spicePkgs.extensions; [
      shuffle         #Reemplaza el algoritmo aleatorio de Spotify por uno realmente aleatorio
      hidePodcasts    
      adblock
      keyboardShortcut
    ];
    enabledCustomApps = with spicePkgs.apps; [
      #marketplace
      ncsVisualizer
    ];
  };


#--------------------------PAQUETES--------------------------
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
#basicos
    github-cli
    vim 
    wget curl 
    hyprlock hyprpaper rofi wev
    brightnessctl
    os-prober efibootmgr
#me esta llegando al huevo q no se actualice correctamente
    waybar
    #docker-compose             no lo utilizo ni creo hacerlo este ciclo
#virtualisacion
    dnsmasq
  ];
#------------------------------------------------------------

  environment.shellAliases = {
    nixwasa = "sudo nixos-rebuild switch --flake /home/falo/.config/nix";
    carajoquieroespacio = "sudo nix-env -p /nix/var/nix/profiles/system --delete-generations old && nix-env --delete-generations old && sudo nix-collect-garbage -d && nix-store --optimize";
    gs = "git status";
    gd = "git diff HEAD .";
    files = "cat /home/falo/.config/nix/configuration.nix && cat /home/falo/.config/nix/home.nix";
    lsd = "lsd --tree --depth=1";
  };

#------------------------------------------------------------
##     AUDIO
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true; 
  };
#brillo
  services.udev.packages = [ pkgs.swayosd ];


##     BLUETOOTH
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

##       FILES
  services.gvfs.enable = true; # Montar discos y soporte de papelera
  services.tumbler.enable = true; # Soporte para miniaturas


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
hardware.steam-hardware.enable = true;


# Además, abre estos puertos UDP específicos que usa L4D2
networking.firewall = {
  enable = true;
  allowedUDPPorts = [ 27015 27016 27031 27036 ];
  allowedTCPPorts = [ 5000 5173 8080 8081 27036 27037 ];
};

##    GRAFICA
services.xserver.videoDrivers = [ "amdgpu" ];

##    DOCKER
#virtualisation.docker.enableNvidia = true;
#virtualisation.docker.enable = true;

##    VIRTUALIZACION
  virtualisation.libvirtd = {
    enable = true;

    qemu = {
 virsh net-list --all     package = pkgs.qemu_kvm;
    };
  };

  programs.virt-manager.enable = true;
  networking.firewall.trustedInterfaces = [ "virbr0" ];


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




