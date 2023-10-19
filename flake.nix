{
# ____flake.nix # NixOS configuration file for Nix Flakes   
#       |___hosts/default.nix 
#                |___configuration.nix
#                |   |___./desktop/desktopconfiguration.nix
#                |              |___hardware-configuration.nix
#                |              |___../../home-manager/gnome/default.nix
#                |              |___../../pograms/flatpak/flatpak.nix
#                |              |___../../pograms/firefox/firefox.nix
#                |              |___../../pograms/lf/lf.nix
#                |
#                |___../home-manager/home.nix
#                              |___gnome/home.nix 

  description = "My NixOS configuration";

# inputs for the flake
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-23.05"; # stable packages

    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable"; # unstable packages 

    programsdb = {
       url = "github:wamserma/flake-programs-sqlite";
       inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05"; # stable home-manager
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master"; # unstable home-manager
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland"; # Add "hyprland.nixosModules.default" to the host moduls list in ./hosts/default.nix
      inputs.nixpkgs.follows = "nixpkgs";
    };  

    plasma-manager = {  # KDE Plasma user settings
      url = "github:pjones/plasma-manager"; # Add "inputs.plasma-manager.homeManagerModules.plasma-manager" to the home-manager.users.${user}.imports list in ./hosts/default.nix
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "nixpkgs";
    };

    
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

# outputs for the flake
  outputs = inputs @ { self, nixpkgs, nixpkgs-unstable, home-manager, hyprland, plasma-manager, ... }:

# variables
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      state-version = "23.05";

      user = "akib";
      theme = "gruvbox-dark-soft";

      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };

      unstable = import nixpkgs-unstable {
        inherit system;
        config = { allowUnfree = true; };
        };

# using the above variables to define the system configuration
  in {

# NixOS configuration
    nixosConfigurations = ( # NixOS configurations
        import ./hosts {    # Imports ./hosts/default.nix
        inherit (nixpkgs) lib;
        inherit inputs unstable user system theme state-version home-manager hyprland plasma-manager;   # Also inherit home-manager so it does not need to be defined here.
        }
      );
  };
}
