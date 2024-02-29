{ pkgs ? import <nixpkgs> { } }:

# you can use this file to install nixos on your system
# nix-shell -p git --command 'nix run github:akibahmed229/nixos#akibOS --experimental-features "nix-command flakes"'
pkgs.writeShellScriptBin "akibOS" ''
  #!/usr/bin/env bash

  # check if internet is working
  if ! ping -c 1 google.com &> /dev/null; then # $> /dev/null is used to hide the output
    echo "No internet connection!"
    exit 1
  fi

  echo "---------------------"
  echo "### Disko Formate ###"
  echo 

  # store user input in function 
  function user_input() {
    read -p "$1: " $2
    echo
  }
  user_input "Enter your username (e.g., akib)" username
  user_input "Enter your hostname (e.g., nixos)" hostname
  user_input "Enter your device (e.g., /dev/sda)" device

  # check if user input is not empty
  if [ -z "$username" ] || [ -z "$hostname" ] || [ -z "$device" ]; then
    echo "Username, hostname, and device are required!"
    exit 1
  fi
  
  # format output
  function my_format() {
    echo
    echo "--------------------"
    echo "$1"
  }

  my_format "### Mounting Disk ###"
  # download disko.nix and run disko
  curl https://raw.githubusercontent.com/akibahmed229/nixos/main/modules/predefiend/nixos/disko/default.nix -o /tmp/disko.nix
  sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/disko.nix --arg device "\"$device\""
  my_format "### Disko Formate Done ###" 
  
 
  # install flake function
  function install_flake() {
    # create persist dir and clone flake
    mkdir -p /mnt/home/$username/flake
    git clone https://www.github.com/akibahmed229/nixos /mnt/home/$username/flake
    rm -rf /mnt/home/$username/flake/flake.lock
    echo
    nixos-install --no-root-passwd --flake /mnt/home/$username/flake#$hostname
  }

  # if dir already exists, remove it 
  if [ -d "/mnt/home" ]; then
    sudo rm -rf /mnt/home
    my_format "### Installing NixOS ###"
    install_flake
  else
    my_format "### Installing NixOS ###"
    install_flake
  fi
''
