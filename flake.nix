{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-23.05"; # stable packages

      nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable"; # unstable packages 

      home-manager = {
        url = "github:nix-community/home-manager/release-23.05"; # stable home-manager
          inputs.nixpkgs.follows = "nixpkgs";
      };

    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = inputs @ { self, nixpkgs, nixpkgs-unstable, home-manager, hyprland, ... }:
    let
    system = "x86_64-linux";
  user = "akib";
  pkgs = import nixpkgs {
    inherit system;
    config = { allowUnfree = true; };
  };
  unstable = import nixpkgs-unstable {
    inherit system;
    config = { allowUnfree = true; };
  };
  lib = nixpkgs.lib;
  in {
    nixosConfigurations = (                                               # NixOS configurations
        import ./hosts {                                                    # Imports ./hosts/default.nix
        inherit (nixpkgs) lib;
        inherit inputs unstable user system home-manager hyprland;   # Also inherit home-manager so it does not need to be defined here.
        }
        );
  };
}
