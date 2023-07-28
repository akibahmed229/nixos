<p align="center"><img src="https://i.imgur.com/X5zKxvp.png" width=300px></p>

<p align="center"><img src="https://i.imgur.com/NbxQ8MY.png" width=600px></p>

<h2 align="center">Akib | My NixOS Config</h2>


## Table of Contents

1. [NixOS Btrfs Installation Guide](#1nixos-btrfs-installation-guide)
    1. [Prerequisites](#installation-prerequisites)
    2. [Installation Steps](#installation-steps)

2. [Home Manager Installation and Usage Guide](#2home-manager-installation-and-usage-guide)
   1. [Prerequisites](#home-manager-prerequisites)
   2. [Standalone Installation](#1-standalone-installation)
   3. [NixOS Module](#2-nixos-module)
 
3. [Using Nix Flakes on NixOS with Home Manager](#3using-nix-flakes-on-nixos-with-home-manager)
    1. [Prerequisites](#flakes-prerequisites)
    2. [Enable Flake](#enable-flake)
    3. [Update System Configuration](#update-system-configuration)
    4. [Using Flakes on Fresh Install](#using-flakes-on-fresh-install)

4. [FAQ](#faq)

# 1. NixOS Btrfs Installation Guide

This guide provides step-by-step instructions for installing NixOS on a Btrfs filesystem using a copy-on-write (CoW) approach for Linux systems.

## Installation Prerequisites

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

# 2. Home Manager Installation and Usage Guide

Home Manager is a powerful tool that allows you to manage user configurations with Nix. It provides a standalone installation method as well as a NixOS module for system-wide user environment configuration. This guide provides step-by-step instructions for installing and using Home Manager in different scenarios.

## 1. Standalone Installation

### Home Manager Prerequisites

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

Sure, I'd be happy to help you create a more detailed and organized guide for using flakes on NixOS in your GitHub repository's README.md. Here's the revised and expanded guide:

# 3. Using Nix Flakes on NixOS with Home Manager

This guide will walk you through setting up and using Nix Flakes on NixOS, along with Home Manager as a module. Flakes provide a declarative and reproducible way to manage NixOS configurations and packages. Home Manager allows you to manage user-specific configurations for applications.

## Flake Prerequisites

- You should be familiar with NixOS and its basic concepts.
- Ensure you have Nix installed on your system.

## Enable Flakes

To enable flakes in your NixOS configuration, follow these steps:

1. Open your `configuration.nix` using a text editor:

   ```bash
   sudo nano /etc/nixos/configuration.nix
   ```

2. Add the following options to the configuration:

   ```nix
   { pkgs, ... }: {
     nix.settings.experimental-features = [ "nix-command" "flakes" ];
   }
   ```

   Save the file and exit the text editor.

3. Rebuild your system to enable flakes:

   ```bash
    sudo nixos-rebuild switch
    ```

## Initialize Flake

1. Create a directory to store your flakes:

   ```bash
   mkdir ~/flake
   cd ~/flake
   ```

2. Initialize the flake using the `nix flake init` command:

   ```bash
   nix flake init
   ```

## Build the System with Flake

To update your system and Home Manager using flakes, run the following command:

```bash
sudo nixos-rebuild switch --flake .#hostname
```

Replace `hostname` with your system's hostname.

## Update System Configuration

If you make changes to your `flake.nix` or update your flake sources, you can update your system with the new configuration using the following commands:

1. Update the flake sources:

   ```bash
   sudo nix flake update
   ```

2. Rebuild your system with the updated flake:

   ```bash
   sudo nixos-rebuild switch --flake .#hostname
   ```

## Using Flakes on Fresh Install

If you want to use your flakes on a fresh NixOS install, follow these steps:

1. Boot into the NixOS installation ISO.

2. Switch to the root user:

   ```bash
   sudo su
   ```

3. Install Nix using Nixpkgs in the ISO:

   ```bash
   nix-env -IA nixos.git
   ```

4. Clone your NixOS configuration repository:

   ```bash
   git clone git@github.com:akibahmed229/nixos.git /mnt/<path>
   ```

5. Install NixOS with your flake:

   ```bash
   nixos-install --flake .#hostname
   ```

   Replace `hostname` with your system's hostname.

6. Reboot your system:

   ```bash
   reboot
   ```

## Finalizing the Setup

After booting into your fresh NixOS system, log in as the user with sudo privileges and complete the following steps:

1. Remove the default `configuration.nix`:

   ```bash
   sudo rm -r /etc/nixos/configuration.nix
   ```

2. Move your built NixOS configuration to the desired location:

   ```bash
   sudo mv /mnt/<path> /home/<user>/flake 
   ```

3. You can now continue using `sudo nixos-rebuild switch --flake .#hostname` to update your system configuration and Home Manager whenever needed.

## Using Nix Flakes on NixOS with Home Manager
Using Nix Flakes on NixOS with Home Manager allows you to manage your NixOS system configuration and user-specific application configurations in a declarative and reproducible way. Nix Flakes provide a convenient way to define your system and package configurations, while Home Manager handles individual user configurations for various applications. With this setup, you can easily update your entire system or specific applications using a single command, ensuring consistency and simplicity in managing your NixOS environment.

# 4. FAQ
- What is NixOS?
  - NixOS is a Linux distribution built on top of the Nix package manager.
  - It uses declarative configurations and allow reliable system upgrades.
- What is a Flake?
  - Flakes are an upcoming feature of the Nix package manager.
  - Flakes allow you to specify your major code dependencies in a declarative way.
  - It does this by creating a flake.lock file. Some major code dependencies are:
    - nixpkgs
    - home-manager
- What is Nix-Darwin?
  - Nix-Darwin is a way to use Nix modules on macOS using the Darwin Unix-based core set of components.
  - Just like NixOS, it allows to build declarative reproducible configurations.
- Should I switch to NixOS?
  - Is water wet?
- Where can I learn about everything Nix?
  - Nix and NixOS
    - [[https://nixos.org/][Website]]
    - [[https://nixos.org/learn.html][Manuals]]
    - [[https://nixos.org/manual/nix/stable/introduction.html][Manual 2]]
    - [[https://search.nixos.org/packages][Packages]] and [[https://search.nixos.org/options?][Options]]
    - [[https://nixos.wiki/][Unofficial Wiki]]
    - [[https://nixos.wiki/wiki/Resources][Wiki Resources]]
    - [[https://nixos.org/guides/nix-pills/][Nix Pills]]
    - [[https://www.ianthehenry.com/posts/how-to-learn-nix/][Some]] [[https://christine.website/blog][Blogs]]
    - [[https://nixos.wiki/wiki/Configuration_Collection][Config Collection]]
    - [[https://nixos.wiki/wiki/Configuration_Collection][Config Collection]]
  - Home-manager
    - [[https://github.com/nix-community/home-manager][Official Repo]]
    - [[https://nix-community.github.io/home-manager/][Manual]]
    - [[https://nix-community.github.io/home-manager/options.html][Appendix A]]
    - [[https://nix-community.github.io/home-manager/nixos-options.html][Appendix B]]
    - [[https://nix-community.github.io/home-manager/tools.html][Appendix D]]
    - [[https://nixos.wiki/wiki/Home_Manager][NixOS wiki]]
  - Flakes
    - [[https://nixos.wiki/wiki/Flakes][NixOS wiki]]
    - [[https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html][Manual]]
    - [[https://www.tweag.io/blog/2020-05-25-flakes/][Some]] [[https://christine.website/blog/nix-flakes-3-2022-04-07][Blogs]]
  - Nix-Darwin
    - [[https://github.com/LnL7/nix-darwin/][Official Repo]]
    - [[https://daiderd.com/nix-darwin/manual/index.html][Manual]]
    - [[https://github.com/LnL7/nix-darwin/wiki][Mini-Wiki]]

# 5. File Structure
```
|____flake
| |____flake.lock
| |____home-manager
| | |____gnome
| | | |____default.nix
| | | |____home.nix
| | |____hyprland
| | | |____default.nix
| | | |____home.nix
| | |____kde
| | | |____default.nix
| | | |____home.nix
| | |____home.nix
| |____hosts
| | |____desktop
| | | |____desktopConfiguration.nix
| | | |____hardware-configuration.nix
| | |____configuration.nix
| | |____default.nix
| |____LICENSE
| |____README.md
| |____programs
| | |____alacritty
| | | |____alacritty.yml
| | |____OpenRGB
| | | |____Mouse.orp
| | | |____Keyboard.orp
| | | |____Mobo.orp
| | |____tmux
| | | |____tmux.conf
| | |____zsh
| | | |____.zshrc
| |____flake.nix
```
