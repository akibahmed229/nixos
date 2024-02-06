{ pkgs ? import <nixpkgs> { } }:

pkgs.writeShellScriptBin "disko-formate" ''
  echo "Enter device (e.g., /dev/vda): "
  read device
  curl https://raw.githubusercontent.com/akibahmed229/nixos/main/modules/predefiend/nixos/disko/disko.nix -o /tmp/disko.nix
  sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/disko.nix --arg device "${device}"
''

