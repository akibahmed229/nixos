
# Arch Linux Installation Guide

This guide provides step-by-step instructions for installing Arch Linux.

## Table of Contents
1. [Keyboard Layout Setup](#1-keyboard-layout-setup)
2. [Connecting to Wi-Fi](#2-connecting-to-wi-fi)
3. [SSH Connection to Another Device](#3-ssh-connection-to-another-device)
4. [Date and Time Setup](#4-date-and-time-setup)
5. [Disk Management for Installation](#5-disk-management-for-installation)
6. [System Installation](#6-system-installation)
7. [Configuring the New Installation (arch-chroot)](#7-configuring-the-new-installation-arch-chroot)
8. [Edit The Mkinitcpio File For Encrypt](#8-edit-the-mkinitcpio-file-for-encrypt)
9. [Grub Installation](#9-grub-installation)
10. [Enabling Systemd Services](#10-enabling-systemd-services)
11. [Creating a New User](#11-creating-a-new-user)
12. [Finishing the Installation](#12-finishing-the-installation)
13. [Post-Installation Configuration](#13-post-installation-configuration)

## 1. Keyboard Layout Setup

Load the keyboard layout using the following commands:
```bash
localectl
localectl list-keymaps
localectl list-keymaps | grep us
loadkeys us
```

Explanation:
- `localectl`: Lists the current keyboard layout settings.
- `localectl list-keymaps`: Lists all available keyboard layouts.
- `localectl list-keymaps | grep us`: Filters the list to show only layouts containing "us" (United States layout).
- `loadkeys us`: Sets the keyboard layout to US.

## 2. Connecting to Wi-Fi

Connect to a Wi-Fi network using the following commands:
```bash
iwctl
device list
station wlan0 get-networks
station wlan0 connect wifiname
ip a
ping -c 5 google.com
```

Explanation:
- `iwctl`: Launches the interactive Wi-Fi control utility.
- `device list`: Lists available network devices.
- `station wlan0 get-networks`: Scans for available Wi-Fi networks.
- `station wlan0 connect wifiname`: Connects to the specified Wi-Fi network (replace "wifiname" with the actual network name).
- `ip a`: Displays the network interfaces and their IP addresses.
- `ping -c 5 google.com`: Pings the Google website to test the internet connection.

## 3. SSH Connection to Another Device

Set a password and establish an SSH connection to another device:
```bash
passwd
ssh root@ipaddress
```

Explanation:
- `passwd`: Sets the password for the current device (root user).
- `ssh root@ipaddress`: Connects to the current device using SSH from another device (replace "ipaddress" with the actual IP address of the current device).

## 4. Date and Time Setup

Set the date and time for the system:
```bash
timedatectl
timedatectl list-timezones
timedatectl list-timezones | grep Dhaka
timedatectl set-timezone Asia/Dhaka
timedatectl
```

Explanation:
- `timedatectl`: Displays the current system time and date settings.
- `timedatectl list-timezones`: Lists all available time zones.
- `timedatectl list-timezones | grep Dhaka`: Filters the list to

 show time zones containing "Dhaka" (replace with your desired time zone).
- `timedatectl set-timezone Asia/Dhaka`: Sets the system's time zone to "Asia/Dhaka" (replace with your desired time zone).
- `timedatectl`: Verifies the updated time and date settings.

## 5. Disk Management for Installation

Manage the disk partitions for the installation:
```bash
lsblk
ls /sys/firmware/efi/efivars
blkid /dev/vda
cfdisk
lsblk
mkfs.btrfs -f /dev/vda1
mkfs.fat -F32 /dev/vda2
blkid /dev/vda
mount /dev/vda1 /mnt
cd /mnt
btrfs subvolume create @
btrfs subvolume create @home
cd
umount /mnt
mount -o noatime,ssd,space_cache=v2,compress=zstd,discard=async,subvol=@ /dev/vda1 /mnt
mkdir /mnt/home
mount -o noatime,ssd,space_cache=v2,compress=zstd,discard=async,subvol=@home /dev/vda1 /mnt/home
mkdir -p /mnt/boot/efi
mount /dev/vda2 /mnt/boot/efi

mkdir /mnt/windows
lsblk
```

Explanation:
- `lsblk`: Lists available block devices and their partitions.
- `ls /sys/firmware/efi/efivars`: Verifies if the system is booted in UEFI mode.
- `blkid /dev/sda`: Displays information about the /dev/sda drive (replace with the appropriate drive if different).
- `cfdisk` : # create two pertion 1. Main file 2. efi partion 

# disk encryption
- `cryptsetup luksformat /dev/vda1`: setup encryption
- `cryptsetup luksOpen /dev/vda1 main`: open your encrypted partition

- `lsblk`: Lists the updated block devices and their partitions after partitioning.
- `mkfs.btrfs -f /dev/mapper/main`: Formats the  System partition (/dev/vda1 or (main)) as Btrfs.
- `mkfs.fat -F32 -f /dev/vda2`: Formats the EFI System partition (/dev/vda2) as FAT32.
- `blkid /dev/vda`: Verifies the UUID of the formatted partition.
- `mount /dev/mapper/main /mnt`: Mounts the System partition (main) to the /mnt directory.
- `cd /mnt`: Changes the current directory to /mnt.
- `fat subvolume create @`: Creates a Btrfs subvolume named "@" for the root directory.
- `fat subvolume create @home`: Creates a Btrfs subvolume named "@home" for the home directory.
- `cd`: Returns to the previous directory.
- `umount /mnt`: Unmounts the /mnt directory.
- `mount -o noatime,ssd,space_cache=v2,compress=zstd,discard=async,subvol=@ /dev/vda1 /mnt`: Mounts the System partition (/dev/vda1) with Btrfs subvolume "@", applying specified mount options.
- `mkdir /mnt/home`: Creates the /mnt/home directory.
- `mount -o noatime,ssd,space_cache=v2,compress=zstd,discard=async,subvol=@home /dev/vda1 /mnt/home`: Mounts the  System partition (/dev/vda1) with Btrfs subvolume "@home" to the /mnt/home directory, applying specified mount options.
- `mkdir -p /mnt/boot/efi`: Creates the /mnt/boot/efi directory.
- `mount /dev/vda1 /mnt/boot/efi`: Mounts the EFI System partition (/dev/vda2) to the /mnt/boot/efi directory.

(Optional) For Windows partition:
- `mkdir /mnt/windows`: Creates the /mnt/windows directory.
- `lsblk`: Lists available block devices and their partitions to identify the Windows partition.

## 6. System Installation

Install the base system:
```bash
reflector --country Bangladesh --age 6 --sort rate --save /etc/pacman.d/mirrorlist
pacman -Sy
pacstrap -K /mnt base linux linux-firmware intel-ucode vim
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
```

Explanation:
- `reflector --country Bangladesh --age 6 --sort rate --save /etc/pacman.d/mirrorlist`: Updates the mirrorlist file with the fastest mirrors in Bangladesh (replace with your desired country).
- `pacman -Sy`: Synchronizes package databases.
- `pacstrap -K /mnt base linux linux-firmware intel-ucode vim`: Installs essential packages (replace with any additional packages you may need).
- `genfstab -U /mnt >> /mnt/etc/fstab`: Generates an fstab file based on the current disk configuration.
- `cat /mnt/etc/fstab`: Displays the contents of the generated fstab file for verification.



## 7. Configuring the New Installation (arch-chroot)

Enter the newly installed system for configuration:
```bash
arch-chroot /mnt
ls
ln -sf /usr/share/zoneinfo/Asia/Dhaka /etc/localtime
hwclock --systohc
vim /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "KEYMAP=us" >> /etc/vconsole.conf
vim /etc/hostname
passwd
pacman -S grub-btrfs efibootmgr networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools reflector base-devel linux-headers bluez bluez-utils cups hplip alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack bash-completion openssh rsync acpi acpi_call tlp sof-firmware acpid os-prober ntfs-3g
```

Explanation:
- `arch-chroot /mnt`: Changes the root to the newly installed system (/mnt).
- `ls`: Lists the contents of the root directory to verify the chroot environment.
- `ln -sf /usr/share/zoneinfo/Asia/Dhaka /etc/localtime`: Creates a symbolic link from the system's time zone file to /etc/localtime, setting the system's time zone to "Asia/Dhaka" (replace with your desired time zone).
- `hwclock --systohc`: Sets the hardware clock from the system clock.
- `vim /etc/locale.gen`: Opens the locale.gen file for editing.
  - Uncomment the line containing "en_US.UTF-8" by removing the leading "#" character.
- `locale-gen`: Generates the locales based on the uncommented entries in locale.gen.
- `echo "LANG=en_US.UTF-8" >> /etc/locale.conf`: Sets the LANG variable in locale.conf to "en_US.UTF-8".
- `echo "KEYMAP=us" >> /etc/vconsole.conf`: Sets the KEYMAP variable in vconsole.conf to "us" (replace with your desired keyboard layout).
- `vim /etc/hostname`: Opens the hostname file for editing.
  - Set the hostname to "arch" (replace with your desired hostname).
- `passwd`: Sets the root password.
- `pacman -S grub efibootmgr networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools reflector base-devel linux-headers bluez bluez-utils cups hplip alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack bash-completion openssh rsync acpi acpi_call tlp sof-firmware acpid os-prober ntfs-3g`: Installs various packages necessary for the system, including GRUB, network management tools, Bluetooth support, printer support, audio utilities, and other useful packages. Adjust the list based on your requirements.

## 8. Edit The Mkinitcpio File For Encrypt

- `vim /etc/mkinitcpio.conf` and search for HOOKS;
- add encrypt (before filesystems hook);
- add `atkbd` to the MODULES (enables external keyboard at device decryption prompt);
- add `btrfs` to the MODULES; and,
- recreate the `mkinitcpio -p linux`

## 9. Grub Installation

Install and configure Grub:
```bash
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

vim /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
```
- run blkid and obtain the UUID for the main partitin: `blkid /dev/vda1`
- edit the grub config `nvim /etc/default/grub`
- `GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet cryptdevice=UUID=d33844ad-af1b-45c7-9a5c-cf21138744b4:main root=/dev/mapper/main`
- make the grub config with `grub-mkconfig -o /boot/grub/grub.cfg`

Explanation:
- `grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB`: Installs GRUB bootloader on the EFI System partition (/dev/vda2) with the bootloader ID "GRUB".
- `grub-mkconfig -o /boot/grub/grub.cfg`: Generates the GRUB configuration file based on the installed operating systems.
- `vim /etc/default/grub`: Opens the GRUB configuration file for editing.
  - Uncomment the line with "os-prober" by removing the leading "#" character. This allows GRUB to detect other installed operating systems.
- `grub-mkconfig -o /boot/grub/grub.cfg`: Generates the GRUB configuration file again to include the changes made.

## 10. Enabling Systemd Services

Enable necessary systemd services:
```bash
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable sshd
systemctl enable tlp
systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable acpid
```

Explanation:
- `systemctl enable NetworkManager`: Enables the NetworkManager service to manage network connections.
- `systemctl enable bluetooth`: Enables the Bluetooth service.
- `systemctl enable cups.service`: Enables the CUPS (Common Unix Printing System) service for printer support.
- `systemctl enable sshd`: Enables the SSH server for remote access.
- `systemctl enable tlp`: Enables the TLP service for power management.
- `systemctl enable reflector.timer`: Enables the Reflector timer to update the mirrorlist regularly.
- `systemctl enable fstrim.timer`: Enables the fstrim timer to trim the filesystem regularly.
- `systemctl enable acpid`: Enables the ACPI (Advanced Configuration and Power Interface) service.
  


## 11. Creating a New User

Create a new user and grant sudo access:
```bash
useradd -m akib
passwd akib
echo "akib ALL=(ALL) ALL" >> /etc/sudoers.d/akib
usermod -c 'Akib Ahmed' akib
exit
```

Explanation:
- `useradd -m akib`: Creates a new user account named "akib" with the `-m` flag to create the user's home directory.
- `passwd akib`: Sets the password for the newly created user "akib".
- `echo "akib ALL=(ALL) ALL" >> /etc/sudoers.d/akib`: Grants sudo access to the user "akib" by adding a sudoers file for the user.
- `usermod -c 'Akib Ahmed' akib`: Sets the user's full name as "Akib Ahmed" (replace with the desired full name).
- `exit`: Exits the chroot environment.

## 12. Finishing the Installation

Unmount partitions and reboot the system:
```bash
umount -R /mnt
reboot
```

Explanation:
- `umount -R /mnt`: Unmounts all the partitions mounted under /mnt.
- `reboot`: Reboots the system.

Once the system reboots, you can log in with the newly created user and continue the setup process.

## 13. Post-Installation Configuration

After logging in with the newly created user, perform the following steps:

```bash
nmtui
```
- Opens the NetworkManager Text User Interface (TUI) for managing network connections.

```bash
ip -c a
```
- Displays the IP addresses and network interfaces for verification.

```bash
grub-mkconfig -o /boot/grub/grub.cfg
```
- Generates the GRUB configuration file to include any changes made during the post-installation steps.

```bash
sudo pacman -S git
```
- Installs the Git package.

```bash
git clone https://aur.archlinux.org/yay-bin.git
```
- Clones the Yay AUR (Arch User Repository) package from the AUR repository.

```bash
ls
cd yay-bin/
makepkg -si
cd
```
- Changes directory to the cloned "yay-bin" directory, builds the package, and installs it using `makepkg`.

```bash
yay
```
- Verifies the successful installation of Yay by running the command.

```bash
yay -S timeshift-bin timeshift-autosnap
```
- Installs the Timeshift packages from the AUR using Yay.

```bash
sudo timeshift --list-devices
```
- Lists the available devices for creating Timeshift snapshots.

```bash
sudo timeshift --snapshot-device /dev/vda1
```
- Sets the device (/dev/vda1) to be used for creating Timeshift snapshots.

```bash
sudo timeshift --create --comments "First Backup" --tags D
```
- Creates a Timeshift snapshot with a comment and assigns it the "D" tag for easy identification.

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```
- Generates the GRUB configuration file again to include any changes made during the post-installation steps.

Ensure you have read and understood each step before proceeding. These additional steps cover various post-installation configurations, including network setup, package installation with Yay, and creating a Timeshift backup.

Happy Arch Linux configuration! 🐧
