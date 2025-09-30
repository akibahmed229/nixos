# Gentoo Installation Guide

This comprehensive guide provides a detailed walkthrough for installing Gentoo Linux. Adjustments may be required based on your specific hardware and preferences.

## Prerequisites

- A reliable internet connection.
- A virtual or physical machine with a target disk (e.g., /dev/vdx).

## 1. Check Internet Connection

Make sure your internet connection is working:

```bash
ping -c 5 www.google.com
```

## 2. Disk Partitioning

Partition your disk using `fdisk`:

```bash
fdisk /dev/vdx
```

Follow these steps in `fdisk`:
- Press `g` for GPT partition.
- Create partitions for boot, swap, and root using `n`.
- Change partition labels using `t`: set boot to EFI, swap to Linux swap.

Format partitions:

```bash
mkfs.vfat -F 32 /dev/vdx1
mkswap /dev/vdx2
swapon /dev/vdx2
mkfs.ext4 /dev/vdx4
```

Mount the root partition:

```bash
mkdir -p /mnt/gentoo
mount /dev/sda3 /mnt/gentoo
```

## 3. Installing a Stage Tarball

Navigate to the Gentoo mirrors and download the stage3 tarball:

```bash
cd /mnt/gentoo
links https://www.gentoo.org/downloads/mirrors/
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
vi /mnt/gentoo/etc/portage/make.conf 
```

In `make.conf`, specify your CPU architecture and core:

```bash
COMMON_FLAGS="-march=alderlake -O2 -pipe"
MAKEOPTS="-j8"
FEATURES="candy parallel-fetch parallel-install"
ACCEPT_LICENSE="*"
```

## 4. Installing the Gentoo Base System

Select a mirror:

```bash
mirrorselect -i -o >> /mnt/gentoo/etc/portage/make.conf
```

Create necessary directories:

```bash
mkdir -p /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
```

Mount essential filesystems:

```bash
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run
```

Chroot into the new environment:

```bash
chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) ${PS1}"
```

Mount the EFI boot partition:

```bash
mkdir /efi
mount /dev/sda1 /efi
```

## 5. Configuring Portage Package Manager of Gentoo

```bash
emerge-webrsync
emerge --sync
emerge --sync --quiet
eselect profile list
eselect profile set 9
emerge --ask --verbose --update --deep --newuse @world
nano /etc/portage/make.conf
```

In `make.conf`, add USE flags:

```bash
USE="-gtk -gnome qt5 kde dvd alsa cdr"
```

Create a `package.license` directory and edit the kernel license:

```bash
mkdir /etc/portage/package.license
nvim /etc/portage/package.license/kernel
```

Add the following licenses:

```bash
app-arch/unrar unRAR
sys-kernel/linux-firmware @BINARY-REDISTRIBUTABLE
sys-firmware/intel-microcode intel-ucode
```

## 6. Timezone and Locale Configuration

Set your timezone:

```bash
ls /usr/share/zoneinfo
echo "Asia/Dhaka" > /etc/timezone
emerge --config sys-libs/timezone-data
```

Configure locales:

```bash
emerge app-editors/neovim
nvim /etc/locale.gen
```

Uncomment the necessary locales and set the default:

```bash
en_US ISO-8859-1
en_US.UTF-8 UTF-8
```

Set the locale:

```bash
locale-gen
eselect locale list
eselect locale set 6
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
```

## 7. Configuring the Kernel

```bash
emerge --ask sys-kernel/linux-firmware
emerge --ask sys-kernel/gentoo-sources
eselect kernel list
eselect kernel set 1
emerge --ask sys-apps/pciutils
cd /usr/src/linux
make menuconfig
make && make modules_install
make install
```

Alternatively, use Genkernel:

```bash
emerge --ask sys-kernel/linux-firmware
emerge --ask sys-kernel/genkernel
genkernel --mountboot --install all
ls /boot/vmlinu* /boot/initramfs*
ls /lib/modules 
```
Or, Use the binary kernel:

```bash
emerge --ask sys-kernel/gentoo-kernel
emerge --ask --autunmust-write sys-kernel/gentoo-kernel-bin
etc-update
emerge -a sys-kernel/gentoo-kernel-bin
```

## 8. Configuring Fstab and Networking

Edit `fstab` to reflect your disk configuration:

```bash
neovim /etc/fstab
```

Add entries for EFI, swap, and root partitions:

```bash
/dev/vdx1   /efi        vfat    defaults    0 2
/dev/vdx2   none        swap    sw          0 0
/dev/vdx3   /           ext4    defaults,noatime 0 1
```

Configure networking:

```bash
echo virt > /etc/hostname
emerge --ask --noreplace net-misc/netifrc
nvim /etc/conf.d/net
```

Add your network configuration:

```bash
config_enp1s0="dhcp"
```

Set networking to start at boot:

```bash
cd /etc/init.d
ln -s net.lo net.enp1s0
rc-update add net.enp1s0 default


```

## 9. Editing Hosts and System Configuration

Edit the hosts file:

```bash
nano /etc/hosts
```

Add or edit the hosts file with appropriate entries:

```bash
127.0.0.1     virt    localhost
::1           virt    localhost
```

Set system information:

```bash
passwd
nano /etc/conf.d/hwclock
```

Edit `hwclock` configuration:

```bash
clock="local"
```

## 10. System Logger and Additional Software

```bash
emerge --ask app-admin/sysklogd
rc-update add sysklogd default
rc-update add sshd default
nano -w /etc/inittab
```

Add SERIAL CONSOLES configuration:

```bash
s0:12345:respawn:/sbin/agetty 9600 ttyS0 vt100
s1:12345:respawn:/sbin/agetty 9600 ttyS1 vt100
```

Install additional software:

```bash
emerge --ask sys-fs/e2fsprogs
emerge --ask sys-block/io-scheduler-udev-rules
emerge --ask net-misc/dhcpcd
emerge --ask net-dialup/ppp
emerge --ask net-wireless/iw net-wireless/wpa_supplicant
```

## 11. Boot Loader

```bash
echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf
emerge --ask --verbose sys-boot/grub
grub-install --target=x86_64-efi --efi-directory=/efi
grub-mkconfig -o /boot/grub/grub.cfg
exit
cd
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -R /mnt/gentoo
reboot
```

## 12. Adding a User for Daily Use

```bash
useradd -m -G users,wheel,audio -s /bin/bash akib
passwd akib
```
Removing Tarballs

```bash
rm /stage3-*.tar.*
```

## 13. Sound (PipeWire) Setup

```bash
emerge -av media-libs/libpulse
emerge --ask media-video/pipewire
emerge --ask media-video/wireplumber
usermod -aG pipewire akib
emerge --ask sys-auth/rtkit
usermod -rG audio akib

mkdir /etc/pipewire
cp /usr/share/pipewire/pipewire.conf /etc/pipewire/pipewire.conf

mkdir ~/.config/pipewire
cp /usr/share/pipewire/pipewire.conf ~/.config/pipewire/pipewire.conf
```

Add the following configuration to `~/.config/pipewire/pipewire.conf`:

```ini
context.properties = {
    default.clock.rate = 192000
    default.clock.allowed-rates = [ 192000 48000 44100 ]  # Up to 16 can be specified
}
```

## 14. Xorg Setup

Edit `/etc/portage/make.conf` and add the following:

```bash
USE="X"
INPUT_DEVICES="libinput synaptics"
VIDEO_CARDS="nouveau"
VIDEO_CARDS="radeon"
```

Install Xorg drivers and server:

```bash
emerge --ask --verbose x11-base/xorg-drivers
emerge --ask x11-base/xorg-server
env-update
source /etc/profile
```

## 15. Setting up Display Manager (SDDM)

```bash
emerge --ask x11-misc/sddm
usermod -a -G video sddm
vim /etc/sddm.conf
```

Add the following lines:

```ini
[X11]
DisplayCommand=/etc/sddm/scripts/Xsetup
```

Create `/etc/sddm/scripts/Xsetup`:

```bash
mkdir -p /etc/sddm/scripts
chmod a+x /etc/sddm/scripts/Xsetup
```

Edit `/etc/conf.d/xdm` and add:

```bash
DISPLAYMANAGER="sddm"
```

Enable the display manager at boot:

```bash
rc-update add xdm default
```

```bash
emerge --ask gui-libs/display-manager-init
vim /etc/conf.d/display-manager
```
From there add,
```bash
		CHECKVT=7
		DISPLAYMANAGER="sddm"
```
after that add it to the service,

```bash
rc-update add display-manager default
rc-service display-manager start
```

## 16. Desktop Installation (KDE Plasma)

```bash
eselect profile list
eselect profile set X
```

Set the number according to the desktop environment you want. For KDE Plasma:

```bash
emerge --ask kde-plasma/plasma-meta
emerge konsole
emerge firefox-bin
```

Create `~/.xinitrc` and add:

```bash
#!/bin/sh
exec dbus-launch --exit-with-session startplasma-x11
```

Feel free to customize this guide further based on your specific needs and preferences.

This guide is designed to provide a comprehensive and detailed walkthrough for installing Gentoo Linux. Feel free to customize it further based on your specific needs and preferences.