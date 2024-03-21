<p align="center"><img src="https://i.imgur.com/NbxQ8MY.png" width=600px></p>

<h2 align="center">Akib | NixOS Config Go Wilde</h2>

<h2 align="center"> Current System Preview </h2>

![my current setup](./public/preview/hyprland.png)

## Table of Contents

1. [NixOS Btrfs Installation Guide](#1-btrfs-installation-my-version-of-nixos)

   - [Prerequisites](#installation-prerequisites)
   - [Installation Steps](#installation-steps)

2. [File Structure](#3-file-structure)

# 1. Installation My version of NixOS

<details>

<summary>NixOS setup using falke and home-manager as module. Hyperland as default Window Manager.</summary>

## Installation Prerequisites

Before you begin, ensure you have the following:

- A Linux system with an EFI-enabled BIOS (for BIOS installations, adjust the commands accordingly).
- The disk identifier (`/dev/sdX`) for the target installation disk. Replace `sdX` with the appropriate disk identifier for your system.

## Installation Steps

**Install NixOS**

```bash
sudo su
nix-shell -p git --command 'nix run github:akibahmed229/nixos#akibOS --experimental-features "nix-command flakes"'
```

Note: During the installation process, [akibOS](./pkgs/akibOS/default.nix) will prompt for the disk identifier (`/dev/sdX`) , hostname and the username. Replace `sdX` with the appropriate disk identifier for your system.
also replace `hostname` with your desired hostname and `username` with your desired username.
the default password for the user is `123456` you can change it later.

Congratulations! You have successfully installed NixOS with a Btrfs filesystem. Enjoy your fault-tolerant, advanced feature-rich, and easy-to-administer system!

For more information about NixOS and its configuration options, refer to the official [NixOS documentation](https://nixos.org/).

</details>

# 2. File Structure

<details>
  <summary>File Structure</summary>

- **Flake.nix** : Main flake file for defining the system configuration

  - **home-manager** : Configuration files for Home Manager and desktop environment
  - **hosts** : Host-specific configuration files
  - **modules** : Program-specific configuration files (includes custom and predefined modules for NixOS and Home Manager)
  - **pkgs** : Nix derivations, custom packages, and shell scripts
  - **public** : Wallpaper folder, GTK, and QT themes
  - **flake.lock** : Lock file for the flake inputs

- **_devShell/flake.nix_** : Flake file defining the development shell
</details>
