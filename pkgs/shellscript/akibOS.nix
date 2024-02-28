{ pkgs ? import <nixpkgs> { } }:

pkgs.writeShellScriptBin "akibOS" ''
  echo "---------------------"
  echo "### Disko Formate ###"
  echo "Enter device (e.g., /dev/nvme0n1): "
  read device
  curl https://raw.githubusercontent.com/akibahmed229/nixos/main/modules/predefiend/nixos/disko/default.nix -o /tmp/disko.nix
  sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/disko.nix --arg device "\"$device\""
  echo "--------------------"
  echo "Disko Formate Done!"
  
  echo "---------------------"
  echo "### Install System ###"

  echo "Enter your username (e.g., akib): "
  nix-shell -p git
  read username
  mkdir -p /mnt/persist/home/$username/flake
  git clone https://www.github.com/akibahmed229/nixos /mnt/persist/home/"$username"/flake
  cd /mnt/persist/home/$username/flake
  echo "Enter your hostname (e.g., deskto): "
  read hostname
  nixos-install --no-root-passwd --flake .#$hostname
''


