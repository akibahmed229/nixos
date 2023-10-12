{
# ____flake.nix # NixOS configuration file for Nix Flakes   
#       |___hosts/default.nix 
#                |___configuration.nix
#                |   |___./desktop/desktopconfiguration.nix
#                |              |___hardware-configuration.nix
#                |              |___../../home-manager/gnome/default.nix
#                |              |___../../pograms/flatpak/flatpak.nix
#                |
#                |___../home-manager/home.nix
#                              |___gnome/home.nix 

  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-23.05"; # stable packages

    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable"; # unstable packages 

    programsdb.url = "github:wamserma/flake-programs-sqlite";
    programsdb.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05"; # stable home-manager
        inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";                  # Add "hyprland.nixosModules.default" to the host moduls list in ./hosts/default.nix
      inputs.nixpkgs.follows = "nixpkgs";
    };  

    plasma-manager = {                                                    # KDE Plasma user settings
      url = "github:pjones/plasma-manager";                               # Add "inputs.plasma-manager.homeManagerModules.plasma-manager" to the home-manager.users.${user}.imports list in ./hosts/default.nix
        inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, nixpkgs-unstable, home-manager, hyprland, plasma-manager, ... }:
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
        inherit inputs unstable user system home-manager hyprland plasma-manager;   # Also inherit home-manager so it does not need to be defined here.
        }
      );

    devShells.${system}.default = (
          import ./shells/python.nix {
            inherit pkgs;
          }
        );

    programs.command-not-found.dbPath = inputs.programsdb.packages.${pkgs.system}.programs-sqlite;
  };
}
