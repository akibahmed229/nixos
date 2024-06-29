let
  getFile = import ./File.nix;

  pkgs = import <nixpkgs> {};

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
  forAllSystems = pkgs.lib.genAttrs systems;
in {
  example1 = getFile.greet "World";

  # example2 = pkgs.lib;

  nixosConfigurations = forAllSystems (getSystem: getSystem);
}
