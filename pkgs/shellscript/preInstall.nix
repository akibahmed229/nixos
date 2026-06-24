{pkgs ? import <nixpkgs> {}}:
# Minimal NixOS pre-install shell application
pkgs.writeShellApplication {
  name = "minimalOS";
  runtimeInputs = with pkgs; [
    git
  ];
  text = ''
    #!/usr/bin/env bash
    set -euo pipefail  # fail fast, treat unset vars as errors

    # --- helpers ----------------------------------------------------------------
    function msg(){ printf "\n---- %s\n" "$1"; }
    function prompt(){ read -rp "$1: " "$2"; printf "\n"; }
    function die()  { echo "ERROR: $1" >&2; exit 1; }

    flake_dir="/mnt/etc/flake"

    # --- gather input -----------------------------------------------------------
    # Check connectivity
    if ! ping -c1 -W1 1.1.1.1 &>/dev/null; then
      msg "No internet connection. Aborting."
      exit 1
    fi

    clear
    prompt "Enter username (e.g. akib)" username
    prompt "Enter hostname (available: desktop, virt)" hostname

    msg "Available block devices:"
    lsblk -dpno NAME,SIZE,MODEL | grep -E "/dev/"
    prompt "Enter device (e.g. /dev/sda)" device
    [ -b "$device" ] || die "Invalid block device: $device"

    prompt "Enter swap amount size or leave blank to use same as mem size" swap_size
    if [[ -z $swap_size   ]]; then
      swap_size=$(free -m -h | awk '/Mem:/ {print int($2) + 1}')
    fi

    if [[ -z "$username" || -z "$hostname" || -z "$device" ]]; then
      msg "username, hostname and device are required"
      exit 1
    fi

    # --- update flake data -----------------------------------------------------
    function update_flake_data(){
      local file="$flake_dir/flake.nix"
      read -rp "Change defaults in $file? (y/N): " ans
      if [[ "$ans" =~ ^[Yy]$ ]]; then
        [[ -f $file ]] || { msg "flake.nix not found at $file"; return; }
        sed -i "s/test/$username/g" "$file"
        msg "flake.nix updated"
      else
        msg "Keeping defaults (you can edit flake.nix later)"
      fi
    }

    # --- generate hardware config if needed -----------------------------------
    function generate_hardware_config(){
      local config_dir="$flake_dir/hosts/x86_64-linux"
      mkdir -p "$config_dir"
      if [[ "$username" == "akib" && "$hostname" == "desktop" || "$hostname" == "virt" ]]; then
        msg "Using bundled hardware-configuration (change later if needed)"
      else
        msg "Generating hardware-configuration.nix"
        nixos-generate-config --root /mnt
        cp -v /mnt/etc/nixos/hardware-configuration.nix "$config_dir/$hostname"
      fi
    }

    # --- install flake and NixOS ------------------------------------------------
    function install_flake(){
      msg "Initializing minimal flake at $flake_dir"
      sudo mkdir -p "$flake_dir"

      # 1. Initialize Git FIRST so you can add files as you go
      pushd "$flake_dir" >/dev/null
      sudo git init

      msg "Formatting disks..."
      # Use full path to the partition script or ensure it's available
      sudo nix --experimental-features "nix-command flakes" run github:akibahmed229/nixos#partition -- "$device" "$swap_size"

      msg "Initializing flake template..."
      sudo nix flake init -t github:akibahmed229/nixos#minimal --experimental-features "nix-command flakes"

      # 2. Add files to Git immediately after they are created
      sudo git add .
      sudo git -c user.name='NixOS Installer' -c user.email='<' commit -m 'Initial setup'

      update_flake_data
      generate_hardware_config

      # 3. Commit the changes made by the helper functions
      sudo git add .
      sudo git commit -m 'Configure hardware and users'

      msg "Running nixos-install..."
      # Since we are already in /mnt/etc/flake, we can use --flake .
      sudo nixos-install --no-root-passwd --flake .#"$hostname"

      popd >/dev/null
    }

    msg "Starting minimal NixOS pre-install"
    install_flake
    msg "Pre-install finished"
  '';
}
