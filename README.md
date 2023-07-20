# NixOS Things ...

# NixOS Btrfs Installation Guide

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
```

Feel free to use the above Markdown content in your `README.md` file on your Git repository. Don't forget to replace the placeholders (e.g., `/dev/sdX`) with the appropriate values for your specific setup.
