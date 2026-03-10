{
  description = "Falo's NixOS Flake Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    antigravity = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs"; # Asegura compatibilidad de paquetes

  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      # IMPORTANTE: Este nombre debe coincidir con tu hostname (networking.hostName)
      nixos-btw = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; }; 
        modules = [
          ./configuration.nix
          ./hardware-configuration.nix
          inputs.spicetify-nix.nixosModules.default
        ];
      };
    };
  };
}
