/*
TODO: Need to structure this file better. It's a bit messy right now.
*/
{
  self,
  inputs,
}: {
  mkNixOSSystem ? null,
  mkHomeManagerSystem ? null,
  mkNixOnDroidSystem ? null,
  mkTemplate ? null,
  mkSystem ? null,
  mkModule ? null,
  pkgsAsFlake ? null,
}: let
  inherit (inputs) nixpkgs;
  inherit (nixpkgs) lib;
  # Supported systems for your flake packages, shell, etc.
  forAllSystems = lib.genAttrs ["aarch64-linux" "i686-linux" "x86_64-linux" "aarch64-darwin" "x86_64-darwin"];

  # The function to generate the system configurations (derived from my custom lib helper function)
  inherit (self.lib) mkDerivation mkOverlay mkModule;
in {
  lib = import ../../lib {inherit lib;}; # Lib is a custom library of helper functions

  # Accessible through 'nix build', 'nix shell', "nix run", etc
  packages = forAllSystems (
    system:
      mkDerivation {
        inherit nixpkgs system;
        path = ../../pkgs;
      }
      // {nixvim = inputs.nixvim.packages.${system}.default;} # TODO: move to a separate module
  );

  # Your custom packages and modifications, exported as overlays
  overlays = mkOverlay {
    inherit inputs;
    path = ../../overlays;
  };
  # available through 'nix fmt'. option: "alejandra" or "nixpkgs-fmt"
  formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra or {});

  # Reusable nixos & home-manager modules you might want to export
  nixosModules = mkModule ../../modules/custom/nixos;
  homeManagerModules = mkModule ../../modules/custom/home-manager;

  # The nixos system configurations for the supported systems
  nixosConfigurations = mkNixOSSystem; # available through "$ nixos-rebuild switch --flake .#host"
  homeConfigurations = mkHomeManagerSystem; # available through "$ home-manager switch --flake .#home"
  nixOnDroidConfigurations = mkNixOnDroidSystem; # available through "$ nix-on-droid switch --flake .#device"
  templates = mkTemplate; # available through "$ nix flake init -t .#template"
}
