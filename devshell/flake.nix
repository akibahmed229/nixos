#
#  Example of a flake shell
#  Can be run with "$ nix develop" or "$ nix develop </path/to/flake.nix>#<host>"
#
{
  description = "My Development Shell Configuration";

# inputs for the flake
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-23.05"; # stable packages

    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable"; # unstable packages 
  };

# outputs for the flake
  outputs = inputs @ { self, nixpkgs, nixpkgs-unstable, ... }:

# variables
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;

      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };

      unstable = import nixpkgs-unstable {
        inherit system;
        config = { allowUnfree = true; };
        };

# using the above variables to define the development configuration
  in {
# DevShell configuration
    devShells.${system} = (
          import ./shell {
            inherit pkgs;
          }
        );
  };
}

