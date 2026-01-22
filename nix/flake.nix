{
  description = "Falo's NixOS Flake Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix/24.11";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs"; # Asegura compatibilidad de paquetes
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      # IMPORTANTE: Este nombre debe coincidir con tu hostname (networking.hostName)
      nixos-btw = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; }; # Esto permite pasar 'inputs' a tus módulos
        modules = [
          ./configuration.nix
          ./hardware-configuration.nix
          inputs.spicetify-nix.nixosModules.default
        ];
      };
    };
  };
}
