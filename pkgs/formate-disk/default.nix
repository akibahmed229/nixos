{ pkgs ? import <nixpkgs> { } }:

pkgs.writeShellScriptBin "disko-formate" ''
  echo "---------------------"
  echo "### Disko Formate ###"
  echo "Enter device (e.g., /dev/vda): "
  read device
  curl https://raw.githubusercontent.com/akibahmed229/nixos/main/modules/predefiend/nixos/disko/disko.nix -o /tmp/disko.nix
  sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/disko.nix --arg device "\"$device\""
  mkdir -p /persist/home
  chown 1000:100 /persist/home
  chmod 700 /persist/home
  echo "--------------------"
  echo "Disko Formate Done!"
''

