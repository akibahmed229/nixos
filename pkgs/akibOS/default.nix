{ pkgs ? import <nixpkgs> { } }:

# you can use this file to install nixos on your system
# nix-shell -p git --command 'nix run github:akibahmed229/nixos#akibOS --experimental-features "nix-command flakes"'
pkgs.writeShellApplication {
  name = "akibOS";

  runtimeInputs = with pkgs; [
    git
  ];

  text = ''
    #!/usr/bin/env bash

    set -eo pipefail  # Exit script on error, treat pipe failures as errors

    # Function to print formatted messages
    function print_message() {
        echo
        echo "--------------------"
        echo "$1"
    }

    # Function to prompt user for input
    function prompt_user() {
        read -rp "$1: " "$2"
        echo
    }

    # Check internet connectivity
    if ! ping -c 1 google.com &> /dev/null; then
        print_message "No internet connection!"
        exit 1
    fi

    # Prompt user for required information
    clear
    prompt_user "Enter your username (e.g., akib)" username
    prompt_user "Enter your hostname (e.g., nixos)" hostname
    prompt_user "Enter your device (e.g., /dev/sda)" device

    # Check if user input is not empty
    if [[ -z "$username" || -z "$hostname" || -z "$device" ]]; then
        print_message "Username, hostname, and device are required!"
        exit 1
    fi

    # Function to update user data in the flake.nix file
    function update_flake_data() {
        local file="/home/$username/flake/flake.nix"
        # Ask the user if they want to change default values
        read -rp "Do you want to change the default values (e.g., username, hostname, and device name)? (y/n): " ans

        # using regex to match the user input
        if [[ "$ans" =~ ^[Yy]$ ]]; then
            # Change values in the flake.nix file according to user input
            sed -i "s/akib/$username/g" "$file"
            sed -i "s/desktop/$hostname/g" "$file"
            sed -i "s,/dev/nvme0n1,$device,g" "$file"
        else
            print_message "You can change it later in flake.nix"
        fi
    }

    # Function to generate hardware-configuration.nix
    function generate_hardware_config() {
        local config_dir="/home/$username/flake/hosts/desktop"

        if [[ "$username" == "akib" && "$hostname" == "desktop" ]] || [[ "$username" == "akib" && "$hostname" == "virt" ]]; then
            print_message "You can change it later in hardware-configuration.nix"
            sleep 1
        else
            # Generate hardware-configuration.nix
            nixos-generate-config --root /mnt
            cp -r "/mnt/etc/nixos/hardware-configuration.nix" "$config_dir"
        fi
    }

    # Function to move the flake directory to the persist directory 
    function move_flake() {
        local flake_dir="$1"
        local persist_dir="$2"
    
        mkdir -p "$persist_dir"
        mv "$flake_dir" "$persist_dir"
        useradd -m $username
        chown -R $username:users $persist_dir/flake/*
        chown -R $username:users $persist_dir/flake/.*
    }

    # Function to install the flake and NixOS
    function install_flake() {
        local flake_dir="/home/$username/flake"
        local persist_dir="/mnt/persist/home/$username/.config"
    
        # check if git is installed
        if ! command -v git &> /dev/null; then
            print_message "Installing ...Git!"
            nix-env -iA nixos.git
        else
            print_message "Git is already installed!"
        fi
        # Clone flake repository
        print_message "Cloning flake repository..."
        git clone https://www.github.com/akibahmed229/nixos "$flake_dir"
        rm -rf "$flake_dir/flake.lock"

        # Update user data and generate hardware configuration
        update_flake_data
        sleep 1
        generate_hardware_config

        # Install NixOS
        nixos-install --no-root-passwd --flake "$flake_dir#$hostname"
        move_flake "$flake_dir" "$persist_dir"
    }

    # Main script logic
    print_message "### Mounting Disk ###"

    # Download disko.nix and run disko
    curl -sSfL https://raw.githubusercontent.com/akibahmed229/nixos/main/modules/predefiend/nixos/disko/default.nix -o /tmp/disko.nix
    sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/disko.nix --arg device "\"$device\""

    print_message "### Disko Format Done ###"

    # Check if /mnt/home directory exists
    if [[ -d "/mnt/home" ]]; then
        sudo rm -rf "/home/$username"
    fi

    print_message "### Installing NixOS ###"
    install_flake
  '';
}
