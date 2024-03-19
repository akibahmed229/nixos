{ pkgs ? import <nixpkgs> { } }:

# you can use this file to install nixos on your system
# nix-shell -p git --command 'nix run github:akibahmed229/nixos#akibOS --experimental-features "nix-command flakes"'
pkgs.stdenv.mkDerivation rec {
  name = "AkibOS 1.0";
  # disable unpackPhase etc
  phases = "buildPhase";
  builder = ./builder.sh;
  nativeBuildInputs = [ git ];
  PATH = lib.makeBinPath nativeBuildInputs;
  # only strings can be passed to builder
  # someString = "hello";
};
