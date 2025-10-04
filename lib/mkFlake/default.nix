{lib}: {
  self,
  inputs,
}: {
  src ? throw "src is required",
  mkNixOSSystem ? {},
  mkHomeManagerSystem ? {},
  mkNixDarwinSystem ? {},
  mkNixOnDroidSystem ? {},
}: let
  inherit
    (inputs)
    nixpkgs
    ;

  # The function to generate the system configurations (derived from my custom lib helper function)
  inherit
    (self.lib)
    mkDerivation
    mkOverlay
    mkModule
    forAllSystems
    ifPathExistsFn
    ifPathExistsSet
    mkSystem
    ;
in {
  lib =
    if lib.pathExists "${src}/lib"
    then (import "${src}/lib" {lib = lib // self.lib;}) # Lib is a custom library of helper functions
    else {};

  # Accessible through 'nix build', 'nix shell', "nix run", etc
  packages =
    ifPathExistsSet "${src}/pkgs"
    (forAllSystems (
      system:
        mkDerivation {
          inherit nixpkgs system;
          path = src + "/pkgs";
        }
    ));

  # Your custom packages and modifications, exported as overlays
  overlays =
    ifPathExistsSet "${src}/overlays"
    (mkOverlay {
      inherit inputs;
      path = src + "/overlays";
    });

  # available through 'nix fmt'. option: "alejandra" or "nixpkgs-fmt"
  formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra or {});

  # Reusable nixos & home-manager modules you might want to export
  nixosModules = ifPathExistsFn "${src}/modules/custom/nixos" mkModule;
  homeModules = ifPathExistsFn "${src}/modules/custom/home-manager" mkModule;

  # The nixos system configurations for the supported systems
  # available through "$ nixos-rebuild switch --flake .#<host>"
  nixosConfigurations = ifPathExistsFn "${src}/hosts/nixos" mkNixOSSystem;

  # available through "$ home-manager switch --flake .#<home>"
  homeConfigurations = ifPathExistsFn "${src}/hosts/homeManager" mkHomeManagerSystem;

  # available through "$ darwin-rebuild build --flake .#<darwin>"
  darwinConfigurations = ifPathExistsFn "${src}/hosts/darwin" mkNixDarwinSystem;

  # available through "$ nix-on-droid switch --flake .#<device>"
  nixOnDroidConfigurations = ifPathExistsFn "${src}/hosts/nixOnDroid" mkNixOnDroidSystem;

  # available through "$ nix flake init -t .#template"
  templates = let
    mkTemplate = mkSystem {
      inherit nixpkgs;
      template = true;
    };
  in
    ifPathExistsFn "${src}/public/templates" mkTemplate
    // ifPathExistsFn "${src}/devshells" mkTemplate;
}
