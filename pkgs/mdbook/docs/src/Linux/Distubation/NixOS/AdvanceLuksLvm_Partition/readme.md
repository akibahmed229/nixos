Here is a comprehensive guide based on your notes, organized into the sections you requested. I've structured the installation and modification guides as step-by-step procedures and added the command references with common examples.

---

# NixOS with LUKS, LVM, and Btrfs: A Comprehensive Guide

This guide covers the installation and management of a NixOS system using a full-disk encryption setup with LUKS, LVM for volume management, and Btrfs for the filesystem.

## 1\. 💿 NixOS Installation: Manual Partitioning with LUKS + LVM + Btrfs

This section guides you through a fresh installation of NixOS on a single disk.

### Prerequisites

1.  Boot the NixOS installer.
2.  Connect to the internet.
3.  Switch to a `root` shell: `sudo -i`.
4.  Identify your target disk: `lsblk`.
5.  Set a variable for your device:
    ```bash
    export DEVICE=/dev/sda
    ```

### Step 1. Wipe Disk and Create Partition Table

🚨 **Warning:** This will destroy all data on the specified disk.

```bash
sgdisk --zap-all ${DEVICE}
```

### Step 2. Create Partitions

We will create a standard 4-partition layout for a modern UEFI system.

```bash
# Partition 1: 1M BIOS Boot partition (for GRUB compatibility)
sgdisk --new=1:0:+1M --typecode=1:EF02 --change-name=1:boot ${DEVICE}

# Partition 2: 500M EFI System Partition (ESP)
sgdisk --new=2:0:+500M --typecode=2:EF00 --change-name=2:ESP ${DEVICE}

# Partition 3: 4G Swap partition
sgdisk --new=3:0:+4G --typecode=3:8200 --change-name=3:swap ${DEVICE}

# Partition 4: The rest of the disk for our encrypted data
# We use 8E00 which is the typecode for "Linux LVM"
sgdisk --new=4:0:0 --typecode=4:8E00 --change-name=4:root ${DEVICE}
```

### Step 3. Format Unencrypted Filesystems

Format the ESP and swap partitions, giving them labels for easy mounting.

```bash
# Format the EFI partition
mkfs.vfat -n ESP ${DEVICE}p2

# Set up the swap partition
mkswap -L swap ${DEVICE}p3
```

### Step 4. Set Up LUKS Encryption and LVM 🔒

This is the core of the setup. We create an encrypted container on our main partition and then build an LVM structure _inside_ it.

```bash
# 1. Create the LUKS encrypted container on the fourth partition.
# You will be prompted to enter and confirm a strong passphrase. Remember this!
echo "Formatting the LUKS container. Please enter your encryption passphrase."
cryptsetup luksFormat --label crypted ${DEVICE}p4

# 2. Open the LUKS container to make it accessible.
# This creates a decrypted "virtual" device at /dev/mapper/crypted.
echo "Opening the LUKS container. Please enter your passphrase."
cryptsetup open ${DEVICE}p4 crypted

# 3. Set up LVM *inside* the decrypted container.
# Initialize the physical volume (PV) on the decrypted device
pvcreate /dev/mapper/crypted

# Create the volume group (VG) named "root_vg"
vgcreate root_vg /dev/mapper/crypted

# Create the logical volume (LV) named "root" that uses all available space
lvcreate -l 100%FREE -n root root_vg
```

### Step 5. Format the LVM Volume with Btrfs

Now, we format the LVM logical volume (not the physical partition) with Btrfs.

```bash
mkfs.btrfs -L root /dev/root_vg/root
```

### Step 6. Create and Mount Btrfs Subvolumes

We use Btrfs subvolumes to separate parts of our system, which is standard practice for NixOS.

```bash
# 1. Mount the top-level Btrfs volume
mount /dev/root_vg/root /mnt

# 2. Create the subvolumes
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/persist
btrfs subvolume create /mnt/nix

# 3. Unmount the top-level volume
umount /mnt

# 4. Mount the root subvolume with correct options
mount -o subvol=root,compress=zstd,noatime /dev/root_vg/root /mnt

# 5. Create the directories for the other mountpoints
mkdir -p /mnt/persist
mkdir -p /mnt/nix
mkdir -p /mnt/boot

# 6. Mount the other subvolumes
mount -o subvol=persist,noatime,compress=zstd /dev/root_vg/root /mnt/persist
mount -o subvol=nix,noatime,compress=zstd /dev/root_vg/root /mnt/nix
```

### Step 7. Mount Boot Partition and Activate Swap

Finish by mounting the ESP and activating the swap.

```bash
# Mount the boot partition
mount ${DEVICE}p2 /mnt/boot

# Activate the swap partition
swapon ${DEVICE}p3
```

### Step 8. Generate NixOS Configuration

Finally, generate the NixOS configuration. The installer will automatically detect the LUKS and LVM setup.

```bash
nixos-generate-config --root /mnt
```

Your `/mnt/etc/nixos/hardware-configuration.nix` will be auto-generated with the correct LUKS and filesystem entries, similar to this:

```nix
# Example /etc/nixos/hardware-configuration.nix

{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # This part is automatically added to unlock your disk at boot
  boot.initrd.luks = {
    devices."crypted" = {
      device = "/dev/disk/by-label/crypted";
      preLVM = true;
    };
  };

  # These are your Btrfs subvolumes
  fileSystems."/" =
    { device = "/dev/mapper/root_vg-root";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  fileSystems."/persist" =
    { device = "/dev/mapper/root_vg-root";
      fsType = "btrfs";
      options = [ "subvol=persist" ];
    };

  fileSystems."/nix" =
    { device = "/dev/mapper/root_vg-root";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

  # Your boot and swap partitions
  fileSystems."/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices =[ { device = "/dev/disk/by-label/swap"; } ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
```

You can now proceed with editing your `configuration.nix` and running `nixos-install`.

---

## 2\. ➕ Extending an Encrypted LVM Volume with a New Disk

Use this guide when you've added a new physical disk (e.g., `/dev/vdb`) and want to add its encrypted space to your existing `root_vg`.

### 🚨 Pre-flight Check: Backup

Before you begin, ensure you have a backup of any critical data.

### Step 1. Partition and Label the New Disk

We'll create a single partition on the new disk (`/dev/vdb`) and give it a partition label for easy identification.

```bash
# Open parted for /dev/vdb
sudo parted /dev/vdb

# Inside parted, run the following commands:
# (parted)
mklabel gpt
mkpart primary 0% 100%
name 1 crypted_ext
quit
```

This creates `/dev/vdb1` and sets its partition name (label) to `crypted_ext`.

### Step 2. Create and Open the LUKS Encrypted Container

Now, encrypt the new partition.

```bash
# Encrypt /dev/vdb1.
# -> IMPORTANT: Use the EXACT SAME password as your main encryption.
# -> This allows NixOS to unlock both with a single password prompt.
sudo cryptsetup luksFormat /dev/vdb1

# Open the new LUKS container so we can work with it.
sudo cryptsetup luksOpen /dev/vdb1 crypted_ext_mapper
```

The unlocked device is now available at `/dev/mapper/crypted_ext_mapper`.

### Step 3. Integrate the New Encrypted Disk into LVM

Add the newly decrypted device as a Physical Volume (PV) to your existing Volume Group (VG).

```bash
# 1. Create a new Physical Volume (PV) on the unlocked container.
sudo pvcreate /dev/mapper/crypted_ext_mapper

# 2. Extend your existing 'root_vg' Volume Group with this new PV.
sudo vgextend root_vg /dev/mapper/crypted_ext_mapper

# 3. (Verification) Check your Volume Group. It should now be larger.
sudo vgs
```

### Step 4. Extend the Logical Volume and Btrfs Filesystem

Make the new space available to your filesystem.

```bash
# 1. Extend the Logical Volume to use 100% of the new free space.
sudo lvextend -l +100%FREE /dev/mapper/root_vg-root

# 2. Resize the Btrfs filesystem to fill the newly expanded Logical Volume.
sudo btrfs filesystem resize max /

# 3. (Verification) Check your disk space.
df -h /
```

### Step 5. Update `configuration.nix`

This is the most critical step. You must tell NixOS to unlock this _second_ device at boot.

Edit your `/etc/nixos/configuration.nix` file and add the new device to `boot.initrd.luks`.

```nix
# Your configuration.nix

boot.initrd.luks = {
  devices."crypted" = {
    device = "/dev/disk/by-label/crypted"; # This is your original /dev/vda4
    preLVM = true;
  };

  # --- ADD THIS NEW BLOCK ---
  devices."crypted_ext" = {
    # Use the partition label you set in Step 1
    device = "/dev/disk/by-partlabel/crypted_ext";
    preLVM = true;
    allowDiscards = true; # Good practice for SSDs/VMs
  };
};
```

> **Note on Passwords:** Because you used the **same password** for both LUKS devices, NixOS will ask for your password **only once** at boot and use it to unlock both containers.

### Step 6. Rebuild and Reboot

**DO NOT REBOOT** until you have applied the new configuration.

```bash
# Apply your new NixOS configuration
sudo nixos-rebuild switch

# Now it is safe to reboot
sudo reboot
```

---

## 3\. ➖ Removing an Encrypted Disk from an LVM Volume

This guide covers the complex process of removing a disk (e.g., `/dev/vdb`) from a Volume Group when your filesystem spans multiple disks.

🚨 **WARNING:** This is a high-risk operation. A mistake can lead to total data loss. **Back up all critical data before proceeding.** This process almost always requires booting from a **Live Linux ISO** because you cannot shrink a mounted root filesystem.

### The Goal

Our goal is to move all data off `/dev/vdb` (which is part of `root_vg`) onto your other disk (`/dev/mapper/crypted`) and then remove `/dev/vdb` from the LVM setup.

### The Problem

You cannot `pvmove` data off `/dev/vdb` because there is no free space on the _other_ disk to move it to. You must first shrink your filesystem and logical volume to be **smaller than the size of the disk you want to keep**.

**Example:**

- Disk 1 (`/dev/mapper/crypted`): 35G
- Disk 2 (`/dev/vdb`): 20G
- Total `root_vg` size: 55G
- **Your Goal:** You must shrink your Btrfs filesystem and LV to **\< 35G** (e.g., 34G).

### Step 1. Boot from a Live Linux ISO

1.  Attach a NixOS, Ubuntu, or other Linux ISO to your VM or machine and boot from it.
2.  Open a terminal.

### Step 2. Unlock Encrypted Disks and Activate LVM

```bash
# 1. Unlock your *main* encrypted partition (the one you are keeping)
# Replace /dev/vda4 with your actual partition
sudo cryptsetup luksOpen /dev/vda4 crypted

# 2. Unlock the *second* disk's encrypted partition
# (This assumes /dev/vdb is encrypted, following the guide in section 2)
sudo cryptsetup luksOpen /dev/vdb1 crypted_ext

# 3. Activate the LVM Volume Group
sudo vgchange -ay
```

### Step 3. Resize Btrfs and LV (Offline)

This is the most critical part.

```bash
# 1. Run a filesystem check (highly recommended)
sudo btrfs check /dev/mapper/root_vg-root

# 2. Shrink the Btrfs filesystem.
# We set it to 34G, which is smaller than our 35G target disk.
sudo btrfs filesystem resize 34G /dev/mapper/root_vg-root

# 3. Shrink the Logical Volume to match.
sudo lvreduce -L 34G /dev/mapper/root_vg-root
```

### Step 4. Reboot into Your Normal System

The offline part is done.

```bash
sudo reboot
```

Remove the Live ISO and boot back into your NixOS. Your system will boot up on a smaller filesystem.

### Step 5. Migrate Data and Remove the Disk (Online)

Now that you are back in your system, `sudo vgs` should show free space in `root_vg`.

```bash
# 1. Load the 'dm-mirror' module, which pvmove needs
sudo modprobe dm_mirror

# 2. Move all data extents off the disk you want to remove.
# This will move data from crypted_ext to the free space on crypted.
sudo pvmove -v /dev/mapper/crypted_ext_mapper

# 3. Remove the now-empty Physical Volume from the Volume Group.
sudo vgreduce root_vg /dev/mapper/crypted_ext_mapper

# 4. Remove the LVM metadata from the device.
sudo pvremove /dev/mapper/crypted_ext_mapper
```

### Step 6. Update `configuration.nix` and Clean Up

1.  Edit your `/etc/nixos/configuration.nix` and **remove** the entry for `crypted_ext` from `boot.initrd.luks`.
2.  Rebuild your system:
    ```bash
    sudo nixos-rebuild switch
    ```
3.  You can now safely close the LUKS container and reboot. The disk `/dev/vdb` is completely free.
    ```bash
    sudo cryptsetup luksClose crypted_ext_mapper
    sudo reboot
    ```

---

## 4\. 📚 LUKS Command Reference

Common `cryptsetup` commands for managing LUKS devices.

- **Format a new LUKS container:**

  ```bash
  # --label is recommended for use in /dev/disk/by-label/
  cryptsetup luksFormat --label crypted /dev/sda4
  ```

- **Open (decrypt) a container:**

  ```bash
  # This creates a device at /dev/mapper/my_decrypted_volume
  cryptsetup luksOpen /dev/sda4 my_decrypted_volume
  ```

- **Close (lock) a container:**

  ```bash
  cryptsetup luksClose my_decrypted_volume
  ```

- **Add a new password (key slot):**

  ```bash
  # You will be prompted for an *existing* password first.
  cryptsetup luksAddKey /dev/sda4
  ```

- **Remove a password:**

  ```bash
  # You will be prompted for the password you wish to remove.
  cryptsetup luksRemoveKey /dev/sda4
  ```

- **View header information (and key slots):**

  ```bash
  cryptsetup luksDump /dev/sda4
  ```

- **Resize an _online_ LUKS container:**
  (Useful if you resize the underlying partition).

  ```bash
  cryptsetup resize my_decrypted_volume
  ```

---

## 5\. 📚 LVM Command Reference

Common commands for managing LVM.

### Physical Volume (PV) - The Disks

- **Initialize a disk for LVM:**
  ```bash
  pvcreate /dev/mapper/crypted
  ```
- **List physical volumes:**
  ```bash
  pvs
  pvdisplay
  ```
- **Move data from one PV to another (within the same VG):**

  ```bash
  # Moves all data *off* /dev/sdb1
  pvmove /dev/sdb1

  # Moves data from /dev/sdb1 *to* /dev/sdc1
  pvmove /dev/sdb1 /dev/sdc1
  ```

- **Remove LVM metadata from a disk:**
  ```bash
  # Only run this *after* removing the PV from its VG.
  pvremove /dev/sdb1
  ```

### Volume Group (VG) - The Pool of Disks

- **Create a new VG:**
  ```bash
  # Creates a VG named "my_vg" using two disks
  vgcreate my_vg /dev/sdb1 /dev/sdc1
  ```
- **List volume groups:**
  ```bash
  vgs
  vgdisplay
  ```
- **Add a disk (PV) to an existing VG:**
  ```bash
  vgextend my_vg /dev/sdd1
  ```
- **Remove a disk (PV) from a VG:**
  ```bash
  # The PV must be empty (use pvmove first).
  vgreduce my_vg /dev/sdb1
  ```
- **Remove a VG:**
  ```bash
  # Make sure all LVs are removed first.
  vgremove my_vg
  ```

### Logical Volume (LV) - The "Partitions"

- **Create a new LV:**

  ```bash
  # Create a 50G LV named "my_lv" from the "my_vg" pool
  lvcreate -L 50G -n my_lv my_vg

  # Create an LV using all remaining free space
  lvcreate -l 100%FREE -n my_other_lv my_vg
  ```

- **List logical volumes:**
  ```bash
  lvs
  lvdisplay
  ```
- **Extend an LV (and its filesystem):**

  ```bash
  # Extend the LV to be 100G in total
  lvresize -L 100G /dev/my_vg/my_lv

  # Add 20G to the LV's current size
  lvresize -L +20G /dev/my_vg/my_lv

  # Extend the LV to use all free space in the VG
  lvextend -l +100%FREE /dev/my_vg/my_lv

  # --- IMPORTANT ---
  # After extending, you must resize the filesystem inside it.
  # For ext4:
  resize2fs /dev/my_vg/my_lv
  # For btrfs:
  btrfs filesystem resize max /path/to/mountpoint
  ```

- **Reduce an LV (and its filesystem):**
  🚨 **DANGEROUS\!** You must shrink the filesystem _first_.

  ```bash
  # 1. Shrink the filesystem (e.g., ext4, UNMOUNTED)
  resize2fs /dev/my_vg/my_lv 40G

  # 2. Shrink the LV to match
  lvreduce -L 40G /dev/my_vg/my_lv

  # For Btrfs, you can often do it online:
  # 1. Shrink Btrfs
  btrfs filesystem resize 40G /path/to/mountpoint
  # 2. Shrink LV
  lvreduce -L 40G /dev/my_vg/my_lv
  ```

- **Remove an LV:**
  ```bash
  # Make sure it's unmounted first.
  lvremove /dev/my_vg/my_lv
  ```

---

## 6\. 📚 Btrfs Command Reference

Common commands for managing Btrfs filesystems and subvolumes.

- **Format a device:**

  ```bash
  # -L sets the label
  mkfs.btrfs -L root /dev/my_vg/my_lv
  ```

- **Resize a filesystem:**

  ```bash
  # Grow to fill the maximum available space (after an lvextend)
  btrfs filesystem resize max /path/to/mountpoint

  # Set to a specific size (e.g., 50G)
  btrfs filesystem resize 50G /path/to/mountpoint

  # Shrink by 10G
  btrfs filesystem resize -10G /path/to/mountpoint
  ```

- **Show filesystem usage:**

  ```bash
  # Btrfs-aware 'df'
  btrfs filesystem df /path/to/mountpoint
  ```

- **Create a subvolume:**

  ```bash
  # Mount the top-level (ID 5) volume first
  mount /dev/my_vg/my_lv /mnt

  # Create subvolumes
  btrfs subvolume create /mnt/root
  btrfs subvolume create /mnt/nix

  umount /mnt
  ```

- **List subvolumes:**

  ```bash
  btrfs subvolume list /path/to/mountpoint
  ```

- **Delete a subvolume:**

  ```bash
  # Deleting a subvolume is recursive and instant
  btrfs subvolume delete /mnt/nix
  ```

- **Create a snapshot:**

  ```bash
  # Create a read-only snapshot of 'root'
  btrfs subvolume snapshot -r /mnt/root /mnt/root-snapshot

  # Create a writable snapshot (a clone)
  btrfs subvolume snapshot /mnt/root /mnt/root-clone
  ```

- **Check a Btrfs filesystem (unmounted):**

  ```bash
  btrfs check /dev/my_vg/my_lv
  ```
