{pkgs ? import <nixpkgs> {}}:
# Minimal NixOS pre-install shell application
pkgs.writeShellApplication {
  name = "minimalOS";
  runtimeInputs = with pkgs; [
    git
    # Add necessary tools if the live environment is minimal
    # E.g., nix, nixos-generate-config, etc.
    # Since this runs on NixOS live ISO, those are usually available,
    # but for robustness, you might want to include them in runtimeInputs.
  ];
  text = ''
    #!/usr/bin/env bash
    set -euo pipefail  # fail fast, treat unset vars as errors

    # --- helpers ----------------------------------------------------------------
    function msg(){ printf "\n---- %s\n" "$1"; }
    function prompt(){ read -rp "$1: " "$2"; printf "\n"; }
    function die()  { echo "ERROR: $1" >&2; exit 1; }

    local flake_dir="/mnt/etc/nixos/flake"
    local config_dir="$flake_dir/hosts/x86_64-linux"

    # --- gather input -----------------------------------------------------------
    # Check connectivity
    if ! ping -c1 -W1 1.1.1.1 &>/dev/null; then
      msg "No internet connection. Aborting."
      exit 1
    fi

    clear
    prompt "Enter username (e.g. akib)" username
    prompt "Enter hostname (e.g. desktop, virt, custom)" hostname

    msg "Available block devices:"
    lsblk -dpno NAME,SIZE,MODEL | grep -E "/dev/"
    prompt "Enter device (e.g. /dev/sda)" device
    [ -b "$device" ] || die "Invalid block device: $device"


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
      mkdir -p "$config_dir/$hostname" # Ensure the host directory exists

      # Check if a bundled config for this hostname exists in the template
      if [[ -f "$config_dir/$hostname/hardware-configuration.nix" ]]; then
        msg "Using bundled hardware-configuration for '$hostname' (change later if needed)"
      else
        msg "Generating hardware-configuration.nix for '$hostname'"

        # Generate the config temporarily in /mnt/etc/nixos
        nixos-generate-config --root /mnt --dir /mnt/etc/nixos

        # Move the generated config into the flake's host directory
        mkdir -p "$config_dir/$hostname"
        cp -v /mnt/etc/nixos/hardware-configuration.nix "$config_dir/$hostname/hardware-configuration.nix"

        # Clean up the default NixOS config files
        rm -f /mnt/etc/nixos/configuration.nix /mnt/etc/nixos/hardware-configuration.nix
      fi
    }

    # --- install flake and NixOS ------------------------------------------------
    function install_flake(){
      msg "Initializing minimal flake at $flake_dir"
      mkdir -p "$flake_dir"

      msg "Formatting disks with declarative NixOS disk partitioning script..."
      # NOTE: This script is responsible for creating and mounting /mnt
      sudo nix --experimental-features "nix-command flakes" run github:akibahmed229/nixos#partition -- "$device"

      pushd "$flake_dir" >/dev/null

      # This command will populate $flake_dir with flake.nix, flake.lock, etc.
      nix flake init -t github:akibahmed229/nixos#minimal --experimental-features "nix-command flakes"

      popd >/dev/null

      # Now that flake.nix exists, we can update it
      update_flake_data
      generate_hardware_config

      msg "Running nixos-install..."
      nixos-install --no-root-passwd --flake "$flake_dir#$hostname"
    }


    msg "Starting minimal NixOS pre-install"
    install_flake
    msg "Pre-install finished"
  '';
}
