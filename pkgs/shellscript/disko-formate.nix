{ pkgs ? import <nixpkgs> { } }:

pkgs.writeShellScriptBin "disko-formate" ''
  echo "---------------------"
  echo "### Disko Formate ###"
  echo "Enter device (e.g., /dev/nvme0n1): "
  read device
  curl https://raw.githubusercontent.com/akibahmed229/nixos/dev/modules/predefiend/nixos/disko/disko.nix -o /tmp/disko.nix
  sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/disko.nix --arg device "\"$device\""
  #mkdir -p /mnt/persist/home/akib
  #chown 1000:100 /mnt/persist/home/akib
  #chmod 700 /mnt/persist/home/akib
  echo "--------------------"
  echo "Disko Formate Done!"
''

