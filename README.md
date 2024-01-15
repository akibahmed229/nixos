<p align="center"><img src="https://i.imgur.com/X5zKxvp.png" width=300px></p>

<p align="center"><img src="https://i.imgur.com/NbxQ8MY.png" width=600px></p>

<h2 align="center">Akib | NixOS Config</h2>

# Current System Preview

[./public/preview/hyprland.png]

## Table of Contents

1. [NixOS Btrfs Installation Guide](#1-btrfs-installation-my-version-of-nixos)

   1. [Prerequisites](#installation-prerequisites)
   2. [Installation Steps](#installation-steps)

2. [FAQ](#2-faq)
3. [File Structure](#3-file-structure)

# 1. Btrfs Installation My version of NixOS

NixOS setup using falke and home-manager as module. Hyperland as default Window Manager.

## Installation Prerequisites

Before you begin, ensure you have the following:

- A Linux system with an EFI-enabled BIOS (for BIOS installations, adjust the commands accordingly).
- The disk identifier (`/dev/sdX`) for the target installation disk. Replace `sdX` with the appropriate disk identifier for your system.

## Installation Steps

1. **Partition the Disk**

Open a terminal and execute the following command to partition the disk:

```bash
fdisk /dev/sdx
```

create gpt label with two partion first one for root,home,nix & second one for efi boot pertion

2. **Format Partitions and Create Subvolumes**

In the same terminal, format the partitions and create subvolumes:

```bash
mkfs.fat -F 32 -n boot /dev/sdX1
mkfs.btrfs -L nixos /dev/sdX2
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
mount -o compress=zstd,subvol=root /dev/disk/by-label/nixos /mnt
mkdir /mnt/{home,nix}
mount -o compress=zstd,subvol=home /dev/disk/by-label/nixos /mnt/home
mount -o compress=zstd,noatime,subvol=nix /dev/disk/by-label/nixos /mnt/nix
mkdir /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
```

4. **Install NixOS**

To install NixOS on the mounted partitions, follow these steps:

```bash
nixos-install --flake github:akibahmed229/nixos/#desktop
```

Note: During the configuration step, you can manually edit the `/mnt/etc/nixos/configuration.nix` file to set mount options and customize your NixOS installation.

Congratulations! You have successfully installed NixOS with a Btrfs filesystem. Enjoy your fault-tolerant, advanced feature-rich, and easy-to-administer system!

Remember to replace `/dev/sdX` with the appropriate disk identifier for your system.

For more information about NixOS and its configuration options, refer to the official [NixOS documentation](https://nixos.org/).

# 2. FAQ

- Where can I learn about everything Nix?
  - Nix and NixOS
    - [Website](https://nixos.org/)
    - [Manuals](https://nixos.org/learn.html)
    - [Manual](https://nixos.org/manual/nix/stable/introduction.html)
    - [Packages](https://search.nixos.org/packages) and [Options](https://search.nixos.org/options?)
    - [Unofficial Wiki](https://nixos.wiki/)
    - [Wiki Resources](https://nixos.wiki/wiki/Resources)
    - [Nix Pills](https://nixos.org/guides/nix-pills/)
    - [Some](https://www.ianthehenry.com/posts/how-to-learn-nix/) [Blogs](https://christine.website/blog)
    - [Config Collection](https://nixos.wiki/wiki/Configuration_Collection)
    - [Config Collection](https://nixos.wiki/wiki/Configuration_Collection)
  - Home-manager
    - [Official Repo](https://github.com/nix-community/home-manager)
    - [Manual](https://nix-community.github.io/home-manager/)
    - [Appendix A](https://nix-community.github.io/home-manager/options.html)
    - [Appendix B](https://nix-community.github.io/home-manager/nixos-options.html)
    - [Appendix D](https://nix-community.github.io/home-manager/tools.html)
    - [NixOS wiki](https://nixos.wiki/wiki/Home_Manager)
  - Flakes
    - [NixOS wiki](https://nixos.wiki/wiki/Flakes)
    - [Manual](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html)
    - [Some](https://www.tweag.io/blog/2020-05-25-flakes/) [Blogs](https://christine.website/blog/nix-flakes-3-2022-04-07)
  - Nix-Darwin
    - [Official Repo](https://github.com/LnL7/nix-darwin/)
    - [Manual](https://daiderd.com/nix-darwin/manual/index.html)
    - [Mini-Wiki](https://github.com/LnL7/nix-darwin/wiki)

# 3. File Structure

- Flake.nix : Main flake file for defining the system configuration
  - home-manager : Home manager configuration files && desktop environment configuration files
  - hosts : Host specific configuration files
  - programs : Program specific configuration files
  - public : Basicly my wallpaper folder
  - themes : GTK and QT themes
- flake.lock : Lock file for the flake
- devShell/flake.nix : Flake file where I define my dev shell
- pkgs/flake.nix : Flake file where I define my nix derivation / custom packages
- nix-update-input/flake.nix : Flake to update the nixpkgs input
