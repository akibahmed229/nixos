#  Can be run with "$ nix develop" or "$ nix develop </path/to/flake.nix>#<host>"
# https://www.nixhub.io/ --> site to search for different versions of packages
{
  description = "My Development Shell Configuration";

  # inputs for the flake
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05"; # stable packages

    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable"; # unstable packages

    # Example of old packages
    python27-pkgs.url = "github:nixos/nixpkgs/272744825d28f9cea96fe77fe685c8ba2af8eb12";
  };

  # outputs for the flake
  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    ...
  }:
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

    pkg = forAllSystems (system:
      import nixpkgs {
        inherit system;
        config = {allowUnfree = true;};
      });

    # The unstable nixpkgs can be used [ e.g., unstable.${system} ]
    pkg-unstable = forAllSystems (system:
      import nixpkgs-unstable {
        inherit system;
        config = {
          android_sdk.accept_license = true;
          allowUnfree = true;
        };
      });
    # using the above variables to define the development configuration
  in {
    # DevShell configuration
    devShells = forAllSystems (system:
      import ./shell {
        inherit system pkg pkg-unstable inputs;
      });
  };
}
