{ pkgs ? import <nixpkgs> { } }:

pkgs.writeShellScriptBin "akibOS" ''
  echo "---------------------"
  echo "### Disko Formate ###"
  echo 
  read -p "Enter device name (e.g., /dev/nvme0n1): " device
  curl https://raw.githubusercontent.com/akibahmed229/nixos/main/modules/predefiend/nixos/disko/default.nix -o /tmp/disko.nix
  sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/disko.nix --arg device "\"$device\""
  echo "--------------------"
  echo "Disko Formate Done!"
  
  echo "---------------------"
  echo "### Install System ###"
  echo

  nix-env -iA nixos.git
  read -p "Enter your username (e.g., akib): " username
  echo
  mkdir -p /home/$username/flake
  git clone https://www.github.com/akibahmed229/nixos /home/$username/flake
  rm -rf /home/$username/flake/flake.lock
  read -p "Enter your hostname (e.g., desktop): " hostname
  echo
  nixos-install --no-root-passwd --flake /home/$username/flake#$hostname
''


