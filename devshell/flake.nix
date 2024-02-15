#  Can be run with "$ nix develop" or "$ nix develop </path/to/flake.nix>#<host>"
# https://www.nixhub.io/ --> site to search for different versions of packages
{
  description = "My Development Shell Configuration";

  # inputs for the flake
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-23.11"; # stable packages

    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable"; # unstable packages 

    # Example of old packages
    python27-pkgs.url = "github:nixos/nixpkgs/272744825d28f9cea96fe77fe685c8ba2af8eb12";
  };

  # outputs for the flake
  outputs = inputs @ { self, nixpkgs, nixpkgs-unstable, ... }:

    # variables
    let
      inherit (nixpkgs) lib;

      # Supported systems for your flake packages, shell, etc.
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      # This is a function that generates an attribute by calling a function you
      # pass to it, with each system as an argument
      forAllSystems = nixpkgs.lib.genAttrs systems;

      pkgs = forAllSystems (system:
        import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        }
      );

      unstable = forAllSystems (system:
        import nixpkgs-unstable
          {
            inherit system;
            config = { allowUnfree = true; };
          }
          nixpkgs-unstable.legacyPackages.${system}
      );

      # using the above variables to define the development configuration
    in
    {
      # DevShell configuration
      devShells = forAllSystems (system:
        import ./shell {
          inherit system pkgs unstable inputs;
        });
    };
}

