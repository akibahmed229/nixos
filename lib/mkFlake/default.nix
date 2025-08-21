/*
TODO: Need to structure this file better. It's a bit messy right now.
*/
{
  self,
  inputs,
}: {
  src ? throw "src is required",
  mkNixOSSystem ? null,
  mkHomeManagerSystem ? null,
  mkNixOnDroidSystem ? null,
  mkTemplate ? null,
  mkSystem ? null,
}: let
  inherit (inputs) nixpkgs;
  inherit (nixpkgs) lib;
  # Supported systems for your flake packages, shell, etc.
  forAllSystems = lib.genAttrs ["aarch64-linux" "i686-linux" "x86_64-linux" "aarch64-darwin" "x86_64-darwin"];

  # The function to generate the system configurations (derived from my custom lib helper function)
  inherit (self.lib) mkDerivation mkOverlay mkModule mkSystem;

  mkTemplate = mkSystem {
    inherit nixpkgs;
    template = true;
  };
in {
  lib = import (src + "/lib") {inherit lib;}; # Lib is a custom library of helper functions

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
  nixosModules = mkModule (src + "/modules/custom/nixos");
  homeModules = mkModule (src + "/modules/custom/home-manager");

  # The nixos system configurations for the supported systems
  nixosConfigurations = mkNixOSSystem (src + "/hosts/nixos"); # available through "$ nixos-rebuild switch --flake .#host"
  homeConfigurations = mkHomeManagerSystem (src + "/hosts/homeManager"); # available through "$ home-manager switch --flake .#home"
  nixOnDroidConfigurations = mkNixOnDroidSystem (src + "/hosts/nixOnDroid"); # available through "$ nix-on-droid switch --flake .#device"
  templates = mkTemplate (src + "/public/templates"); # available through "$ nix flake init -t .#template"
}
