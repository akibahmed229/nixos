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
      mkdir -p "$flake_dir"
      pushd "$flake_dir" >/dev/null


      msg "Formatting disks with declarative NixOS disk partitioning script..."
      # Using sudo here because nixos-partition-luks needs root privileges to modify disks
      sudo nix --experimental-features "nix-command flakes" run github:akibahmed229/nixos#partition -- "$device"

      # Using sudo for nix flake init because the parent dir /mnt/etc is owned by root
      sudo nix flake init -t github:akibahmed229/nixos#minimal --experimental-features "nix-command flakes"

      # The flake files are now owned by root, so subsequent commands also need sudo
      sudo update_flake_data
      sudo generate_hardware_config

      # --- FIX STARTS HERE ---
      # Turn the flake directory into a clean Git repository so Nix can hash it reliably.
      msg "Committing flake to a temporary git repository"
      sudo git init
      sudo git add .
      # This git user config is temporary and local to this command
      sudo git -c user.name='NixOS Installer' -c user.email='<' commit -m 'Initial commit'
      # --- FIX ENDS HERE ---

      msg "Running nixos-install..."
      # The flake path needs to be owned by the user running nixos-install (root).
      # The commands above ensure this.
      sudo nixos-install --no-root-passwd --flake "$flake_dir#$hostname"
      popd >/dev/null
    }

    msg "Starting minimal NixOS pre-install"
    install_flake
    msg "Pre-install finished"
  '';
}
