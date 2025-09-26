/*
TODO: Need to structure this file better. It's a bit messy right now.
*/
{lib}: {
  self,
  inputs,
}: {
  src ? throw "src is required",
  mkNixOSSystem ? {},
  mkHomeManagerSystem ? {},
  mkNixOnDroidSystem ? {},
  mkTemplate ? {},
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
    ;
in {
  lib = import "${src}/lib" {lib = lib // self.lib;}; # Lib is a custom library of helper functions

  # Accessible through 'nix build', 'nix shell', "nix run", etc
  packages = forAllSystems (
    system:
      mkDerivation {
        inherit nixpkgs system;
        path = src + "/pkgs";
      }
  );

  # Your custom packages and modifications, exported as overlays
  overlays = mkOverlay {
    inherit inputs;
    path = src + "/overlays";
  };
  # available through 'nix fmt'. option: "alejandra" or "nixpkgs-fmt"
  formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra or {});

  # Reusable nixos & home-manager modules you might want to export
  nixosModules = mkModule "${src}/modules/custom/nixos";
  homeModules = mkModule "${src}/modules/custom/home-manager";

  # The nixos system configurations for the supported systems
  # available through "$ nixos-rebuild switch --flake .#host"
  nixosConfigurations = mkNixOSSystem "${src}/hosts/nixos";

  # available through "$ home-manager switch --flake .#home"
  homeConfigurations = mkHomeManagerSystem "${src}/hosts/homeManager";

  # available through "$ nix-on-droid switch --flake .#device"
  nixOnDroidConfigurations = mkNixOnDroidSystem "${src}/hosts/nixOnDroid";

  # available through "$ nix flake init -t .#template"
  templates = mkTemplate "${src}/public/templates";
}
