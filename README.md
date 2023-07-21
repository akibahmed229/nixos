# NixOS Things ...

# 1.NixOS Btrfs Installation Guide

This guide provides step-by-step instructions for installing NixOS on a Btrfs filesystem using a copy-on-write (CoW) approach for Linux systems.

## Prerequisites

Before you begin, ensure you have the following:

- A Linux system with an EFI-enabled BIOS (for BIOS installations, adjust the commands accordingly).
- The disk identifier (`/dev/sdX`) for the target installation disk. Replace `sdX` with the appropriate disk identifier for your system.

## Installation Steps

1. **Partition the Disk**

Open a terminal and execute the following command to partition the disk:

```bash
printf "label: gpt\n,550M,U\n,,L\n" | sfdisk /dev/sdX
```

2. **Format Partitions and Create Subvolumes**

In the same terminal, format the partitions and create subvolumes:

```bash
mkfs.fat -F 32 /dev/sdX1
mkfs.btrfs /dev/sdX2
mkdir -p /mnt
mount /dev/sdX2 /mnt
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/nix
umount /mnt
```

3. **Mount the Partitions and Subvolumes**

Mount the partitions and subvolumes using the following commands:

```bash
mount -o compress=zstd,subvol=root /dev/sdX2 /mnt
mkdir /mnt/{home,nix}
mount -o compress=zstd,subvol=home /dev/sdX2 /mnt/home
mount -o compress=zstd,noatime,subvol=nix /dev/sdX2 /mnt/nix
mkdir /mnt/boot
mount /dev/sdX1 /mnt/boot
```

4. **Install NixOS**

To install NixOS on the mounted partitions, follow these steps:

```bash
nixos-generate-config --root /mnt
nano /mnt/etc/nixos/configuration.nix # manually add mount options
nixos-install
```

Note: During the configuration step, you can manually edit the `/mnt/etc/nixos/configuration.nix` file to set mount options and customize your NixOS installation.

Congratulations! You have successfully installed NixOS with a Btrfs filesystem. Enjoy your fault-tolerant, advanced feature-rich, and easy-to-administer system!

Remember to replace `/dev/sdX` with the appropriate disk identifier for your system.


For more information about NixOS and its configuration options, refer to the official [NixOS documentation](https://nixos.org/).

# 2.Home Manager Installation and Usage Guide

Home Manager is a powerful tool that allows you to manage user configurations with Nix. It provides a standalone installation method as well as a NixOS module for system-wide user environment configuration. This guide provides step-by-step instructions for installing and using Home Manager in different scenarios.

## 1. Standalone Installation

### Prerequisites

Before you begin, ensure you have the following:

1. A working Nix installation, allowing your user to build and install Nix packages without root access.
2. Add the appropriate Home Manager channel based on your Nixpkgs version:

   - For Nixpkgs master or an unstable channel:
     ```bash
     nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
     nix-channel --update
     ```
   - For Nixpkgs version 23.05 channel:
     ```bash
     nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz home-manager
     nix-channel --update
     ```

### Home Manager Installation

Follow these steps to install Home Manager:

1. Run the Home Manager installation command and create the first Home Manager generation:
   ```bash
   nix-shell '<home-manager>' -A install
   ```

2. Once the installation is finished, Home Manager should be active and available in your user environment.

### Shell Configuration

If you don't want Home Manager to manage your shell configuration, follow the appropriate steps below:

- For Bash or Z shell users, add the following line to your `~/.profile` file:
  ```bash
  . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
  ```

- Fish shell users can consider using utilities like `foreign-env` or `babelfish` to handle sourcing.

 3. To activate the Home Manager configuration, run the following command:
    ```bash
    home-manager switch
    ``` 

## 2. NixOS Module

Home Manager provides a NixOS module that allows you to configure user environments directly from the system configuration file. This is especially useful when managing user environments in NixOS declarative containers or systems deployed via NixOps.

### Installation

To use the NixOS module, follow these steps:

1. Make the NixOS module available by adding the Home Manager channel to the root user:
   - For Nixpkgs master or an unstable channel:
     ```bash
     sudo nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
     sudo nix-channel --update
     ```
   - For Nixpkgs version 23.05 channel:
     ```bash
     sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz home-manager
     sudo nix-channel --update
     ```

2. Import the Home Manager NixOS module in your `system configuration.nix` file:
   ```nix
   { config, pkgs, ... }:

   {
     imports = [ <home-manager/nixos> ];
     # Further configuration options can be set here.
   }
   ```

3. Define Home Manager configurations for specific users using the `home-manager.users` option.

## Using Home Manager

For more detailed information and usage instructions, refer to [Chapter 2 of the Home Manager documentation](https://nix-community.github.io/home-manager/index.html#sec-installation). This documentation provides comprehensive guidance on managing your user environment configurations with Home Manager. It enables you to create a powerful, reproducible, and customizable user experience with Nix.

Feel free to explore and experiment with Home Manager to tailor your user environment configuration to your specific needs. Enjoy the flexibility and simplicity of managing your system with Nix and Home Manager!

# File Structure
```
|____flake
| |____flake.lock
| |____home-manager
| | |____alacritty
| | | |____alacritty.yml
| | |____OpenRGB
| | | |____Mouse.orp
| | | |____Keyboard.orp
| | | |____Mobo.orp
| | |____home.nix
| |____hosts
| | |____desktop
| | | |____tmux.conf
| | | |____.zshrc
| | | |____hardware-configuration.nix
| | |____default.nix
| | |____configuration.nix
| |____flake.nix
| |____README.md
| |____LICENSE
| |____.gitignore
| |____.git

```
