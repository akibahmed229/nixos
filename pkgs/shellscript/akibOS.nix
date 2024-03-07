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

  # format output
  function my_format() {
    echo
    echo "--------------------"
    echo "$1"
  }

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

  my_format "### Mounting Disk ###"
  # download disko.nix and run disko
  curl https://raw.githubusercontent.com/akibahmed229/nixos/main/modules/predefiend/nixos/disko/default.nix -o /tmp/disko.nix
  sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/disko.nix --arg device "\"$device\""
  my_format "### Disko Formate Done ###" 

  # Change in file accroding to input 
  function writeUserData() {
    user_input "Do you want write $username , $hostname, & $device in flake.nix (y/n): " ans

    # if user input is not empty and is y 
    if [ -z "$ans"] && [ "$ans" == "y" || "$ans" == "Y" ]; then
      # change in flake.nix file according to user input
      sed -i "s/akib/$username/g" /home/$username/flake/flake.nix
      sed -i "s/nixos/$hostname/g" /home/$username/flake/flake.nix
      sed -i "s/\/dev\/nvme0n1/$device/g" /home/$username/flake/flake.nix
    else
      echo "You can change it later in flake.nix"
    fi
  }

  function generateHardwareConfig() {
    if [ "$username" == "akib" ]; then
      return
    else
    # generate hardware-configuration.nix
    nixos-generate-config --root /mnt
    cp -r /mnt/etc/nixos/hardware-configuration.nix /home/$username/flake/hosts/desktop/hardware-configuration.nix
    fi
  }
 
  # install flake function
  function install_flake() {
    # create persist dir and clone flake
    mkdir -p /home/$username/flake
    git clone https://www.github.com/akibahmed229/nixos /home/$username/flake
    rm -rf /home/$username/flake/flake.lock
    nix flake update /home/$username/flake/ --experimental-features "nix-command flakes"
    
    writeUserData
    generateHardwareConfig
    # install nixos
    nixos-install --no-root-passwd --flake /home/$username/flake#$hostname
    mv /home/$username/flake /mnt/persist/home/$username/.config/
  }

  # if dir already exists, remove it 
  if [ -d "/mnt/home" ] && [ -d /mnt/persist/home; then
    sudo rm -rf /home/$username
    sudo rm -rf /mnt/persist/home/$username/.config/flake
    my_format "### Installing NixOS ###"
    install_flake
  else
    my_format "### Installing NixOS ###"
    install_flake
  fi
''
