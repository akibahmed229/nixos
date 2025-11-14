{pkgs ? import <nixpkgs> {}}:
pkgs.writeShellApplication {
  name = "nixos-partition-luks";

  # This makes all necessary tools available in the script's PATH.
  runtimeInputs = with pkgs; [
    gptfdisk # For sgdisk
    cryptsetup # For LUKS
    lvm2 # For pvcreate, vgcreate, lvcreate
    btrfs-progs # For mkfs.btrfs and btrfs subvolume
    dosfstools # For mkfs.vfat
    util-linux # For mkswap, swapon, mount
  ];

  # The script itself, with added safety checks and user interaction.
  text = ''
    #!/usr/bin/env bash
    set -euo pipefail

    # --- Color Codes ---
    C_RED='\e[31m'
    C_GREEN='\e[32m'
    C_YELLOW='\e[33m'
    C_BOLD='\e[1m'
    C_RESET='\e[0m'

    # --- Argument and Sanity Checks ---
    if [ "$#" -ne 2 ]; then
      echo -e "$C_RED""Error: You must provide exactly two argument: the target disk device & swap size.$C_RESET"
      echo "Usage: nix run .#partition -- /dev/sdX 4"
      exit 1
    fi

    DEVICE="$1"
    SWAP_SIZE="$2"

    if [ ! -b "$DEVICE" ]; then
      echo -e "$C_RED""Error: The device '$DEVICE' does not exist or is not a block device.$C_RESET"
      lsblk
      exit 1
    fi

    if [[ "$DEVICE" == *"nvme"* ]]; then
      DEVICE2="$DEVICE"p2
      DEVICE3="$DEVICE"p3
      DEVICE4="$DEVICE"p4
    else
      DEVICE2="$DEVICE"2
      DEVICE3="$DEVICE"3
      DEVICE4="$DEVICE"4
    fi

    # --- THE BIG SCARY WARNING ---
    echo -e "$C_RED""$C_BOLD""!!! WARNING !!!$C_RESET"
    echo -e "$C_RED""This script is about to WIPE ALL DATA from the disk: $C_BOLD$DEVICE$C_RESET"
    echo -e "$C_RED""This action is IRREVERSIBLE.$C_RESET"
    echo -e "$C_YELLOW""Please double-check that this is the correct disk.$C_RESET"
    lsblk
    read -rp "Type 'YES' to continue, or anything else to abort: " REPLY
    if [[ "$REPLY" != "YES" ]]; then
      echo "Aborting."
      exit 0
    fi

    # --- Get LUKS Passphrase ---
    echo -e "$C_YELLOW""Please enter the passphrase for disk encryption.$C_RESET"
    read -rsp "Passphrase: " LUKS_PASSWORD
    echo
    read -rsp "Confirm Passphrase: " LUKS_PASSWORD_CONFIRM
    echo
    if [ "$LUKS_PASSWORD" != "$LUKS_PASSWORD_CONFIRM" ]; then
      echo -e "$C_RED""Error: Passphrases do not match. Aborting.$C_RESET"
      exit 1
    fi

    # --- Partitioning Steps ---
    echo -e "$C_GREEN""\n--- 1. Wiping disk and creating partition table on $DEVICE... ---$C_RESET"
    # Disk uses LVM. Before wiping, it's a good practice to deactivate the volume group.
    vgchange -a n root_vg
    sgdisk --zap-all "$DEVICE"

    echo -e "$C_GREEN""\n--- 2. Creating partitions... ---$C_RESET"
    sgdisk --new=1:0:+500M --typecode=1:EF02 --change-name=1:boot "$DEVICE"
    sgdisk --new=2:0:+1G --typecode=2:EF00 --change-name=2:ESP "$DEVICE"
    sgdisk --new=4:0:0 --typecode=4:8E00 --change-name=4:root "$DEVICE"

    echo -e "$C_GREEN""\n--- 3. Formatting unencrypted filesystems... ---$C_RESET"
    mkfs.vfat -n ESP "$DEVICE2"

    echo -e "$C_GREEN""\n--- 4. Setting up LUKS encryption and LVM... ---$C_RESET"
    echo "Formatting LUKS container on $DEVICE4 ..."
    cryptsetup luksFormat -v -s 512 -h sha512 --label crypted "$DEVICE4" <<< "$LUKS_PASSWORD"

    echo "Opening LUKS container..."
    cryptsetup open "$DEVICE4" crypted <<< "$LUKS_PASSWORD"

    echo "Setting up LVM on /dev/mapper/crypted..."
    pvcreate /dev/mapper/crypted
    vgcreate root_vg /dev/mapper/crypted
    lvcreate -L "$SWAP_SIZE"G -n swap root_vg
    lvcreate -l 100%FREE -n root root_vg

    echo -e "$C_GREEN""\n--- 5. Formatting the LVM volume with Btrfs... ---$C_RESET"
    mkfs.btrfs -L root /dev/root_vg/root

    echo -e "$C_GREEN""\n--- 6. Creating and mounting Btrfs subvolumes... ---$C_RESET"
    mount /dev/root_vg/root /mnt
    btrfs subvolume create /mnt/root
    btrfs subvolume create /mnt/persist
    btrfs subvolume create /mnt/nix
    umount /mnt

    mount -o subvol=root,compress=zstd,noatime /dev/root_vg/root /mnt
    mkdir -p /mnt/persist /mnt/nix /mnt/boot
    mount -o subvol=persist,noatime,compress=zstd /dev/root_vg/root /mnt/persist
    mount -o subvol=nix,noatime,compress=zstd /dev/root_vg/root /mnt/nix

    echo -e "$C_GREEN""\n--- 7. Mounting boot partition and activating swap... ---$C_RESET"
    mount "$DEVICE2" /mnt/boot
    swapon "$DEVICE3"

    echo -e "$C_GREEN""\n--- ✅ Partitioning Complete! ---$C_RESET"
    echo "Your disk is partitioned, encrypted, and mounted at /mnt."
    echo "The next step is to run: nixos-generate-config --root /mnt"
  '';
}
