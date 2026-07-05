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
    
    DEFAULT_BROWSER = "${inputs.zen-browser.packages."${pkgs.system}".default}/bin/zen";
  };

# PROGRAMAS
  home.packages = with pkgs; [
# bare minimum
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
    drawing
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
    (pkgs.lib.hiPrio gcc)
    gnumake
    clang
    rustc          # Añadido para compilar con rust
    cargo          # Gestor de paquetes/entorno de Rust
    (python3.withPackages (ps: with ps; [
      matplotlib
      numpy
      fastapi
      uvicorn
      python-multipart
      httpx
      scikit-learn
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
    #inputs.antigravity.packages.${pkgs.system}.default
    antigravity
    code-cursor
    postman

    #jetbrains.idea
    jetbrains.clion
    #jetbrains.webstorm
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
    obs-studio
    google-chrome
#terriblemente estetica
    bibata-cursors
#juego
    armagetronad
#testeo
    sony-headphones-client

  ];

## ----------------- TERMINAL -----------------------------
# STARSHIP
  programs.starship = {
    enable = true;
    enableZshIntegration = true; # <-- Añade esto para que se muestre en Zsh
    settings = {
    add_newline = false;
    };
  };
# KITTY
  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
      background_opacity = "0.8";
      shell = "zsh";
    };
  };
  # En tu home.nix:
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
    };
    initContent = ''
      #bindkey '^I' autosuggest-accept
      cppa() {
        if [ -z "$1" ]; then
          echo "Error: Falta el archivo. q vas a compilar ps xdd"
          return 1
        fi

        local nombre="''${1%.cpp}"
        mkdir -p output
        g++ "$1" -o "output/$nombre.out" && "./output/$nombre.out"
      }
      bindkey '^[^?' backward-kill-word

    '';
  };
  programs.bash.enable = true;
# YAZI
programs.yazi = {
  enable = true;
  shellWrapperName = "y";
  settings = {
    opener = {
      zen = [
        { run = ''zen "$@"''; block = false; desc = "Zen Browser"; }
      ];
    };
    open = {
      prepend_rules = [
        { url = "*.pdf"; use = "zen"; }
      ];
    };
  };
};
## -----------------          -----------------------------

# -------------------------------- NEOVIM
programs.neovim = {
  enable = true;
  defaultEditor = true;
  withRuby = false;   
  withPython3 = false;
  plugins = with pkgs.vimPlugins; [
    nvim-treesitter.withAllGrammars
    indent-blankline-nvim
  ];
  initLua = ''
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
    setSessionVariables = true;
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
      "video/mp4" = [ "mpv.desktop" ];
      "video/quicktime" = [ "mpv.desktop" ]; # para archivos .mov
      "video/x-matroska" = [ "mpv.desktop" ]; # para archivos .mkv
      "video/webm" = [ "mpv.desktop" ];
      "text/txt" = [ "nvim.desktop" ];
      "text/html" = [ "zen.desktop" ];
      "application/pdf" = [ "zen.desktop" ];
      "x-scheme-handler/http" = [ "zen.desktop" ];
      "x-scheme-handler/https" = [ "zen.desktop" ];
      "x-scheme-handler/about" = [ "zen.desktop" ];
    };
  };
#-------------------- NEOVIM DESKTOP OVERRIDE
  xdg.desktopEntries.nvim = {
    name = "Neovim";
    genericName = "Text Editor";
    exec = "kitty -e nvim %F"; 
    terminal = false; 
    categories = [ "Utility" "TextEditor" ];
    mimeType = [ "text/plain" "text/txt" ];
  };
#BRILLO
  services.swayosd.enable = true;





#-----------------------
  home.stateVersion = "25.11"; 
  programs.home-manager.enable = true;
}
