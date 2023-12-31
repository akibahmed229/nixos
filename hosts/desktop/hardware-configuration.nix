# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, unstable, self, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # use the latest Linux kernel
  #   boot.kernelPackages = pkgs.linuxPackages_latest;
  #  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  boot.kernelPackages = unstable.linuxPackages_zen;

  boot.kernelParams = [
    "i915.force_probe=4680" # Force the i915 driver to load for the Intel Iris Xe Graphics
    "nohibernate" # Disable hibernation
    "intel_iommu=on" # Enable IOMMU 
    "acpi_backlight=vendor" # Fix backlight control 
    "acpi_osi=Linux" # Fix backlight control 
    "acpi_sleep=nonvs" # pecific kernel parameters to enable proper power 
    "rd.udev.log_level=3" # Increase kernel log verbosity
    "systemd.show_status=false"
    "no_console_suspend" # Prevent consoles from being suspended
    "splash"
    "logo.nologo"
  ];

  boot = {
    consoleLogLevel = 3;
    initrd = {
      verbose = false;
      systemd.enable = true;
    };
    plymouth = {
      enable = true;
      theme = "breeze";
    };
  };

  boot.initrd.availableKernelModules = [
    "xhci_pci" # USB 3.0 (eXtensible Host Controller Interface)
    "ehci_pci" # USB 2.0 (Enhanced Host Controller Interface)
    "rtsx_pci_sdmmc" # Realtek PCI-E SD/MMC Card Host Driver
    "ahci" # SATA devices on modern AHCI controllers
    "nvme" # NVMe drives (really fast SSDs)
    "usbhid" # USB Human Interface Devices
    "usb_storage" # Utilize USB Mass Storage (USB flash drives)
    "sd_mod" # SCSI, SATA, and PATA (IDE) devices
    "sdhci_pci" # Secure Digital Host Controller Interface (SD cards)
    "uas" # USB attached SCSI drives
    "virtio_blk" # Another Virtio module, enabling high-performance communication between the host and virtualized block devices (e.g., hard drives) in a virtualized environment.
    "virtio_pci" # Part of Virtio virtualization standard, it supports efficient communication between the host and virtual machines with PCI bus devices.
  ];
  boot.initrd.kernelModules = [
    "cifs" #  implementation of the Server Message Block (SMB) protocol, is used to share file systems, printers, or serial ports over a network. 
    "dm-snapshot" #  a read-only copy of the entire file system and all the files contained in the file system. 
  ];
  boot.kernelModules = [
    "kvm-intel" # KVM on Intel CPUs
    "coretemp" # Temperature monitoring on Intel CPUs
    "fuse" # userspace filesystem framework.
    "i2c-dev" # An acronym for the “Inter-IC” bus, a simple bus protocol which is widely used where low data rate communications suffice.
    "i2c-piix4"
  ];
  boot.extraModulePackages = [
    config.boot.kernelPackages.openrazer
  ];

  boot.supportedFilesystems = [ "ntfs" "ntfs-3g" "btrfs" "exFAT" ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-label/nixos";
      fsType = "btrfs";
      options = [ "subvol=root" "ssd" "noatime" "compress=zstd" "space_cache=v2" "discard=async" ];
    };

  fileSystems."/home" =
    {
      device = "/dev/disk/by-label/nixos";
      fsType = "btrfs";
      options = [ "subvol=home" "ssd" "noatime" "compress=zstd" "space_cache=v2" "discard=async" ];
    };

  fileSystems."/nix" =
    {
      device = "/dev/disk/by-label/nixos";
      fsType = "btrfs";
      options = [ "subvol=nix" "ssd" "compress=zstd" "noatime" "space_cache=v2" "discard=async" ];
    };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  fileSystems."/mnt/sda1" = {
    device = "/dev/sda1";
    fsType = "ntfs"; # Specify the file system type
    options = [ "rw" ]; # Mount options 
  };

  fileSystems."/mnt/sda2" = {
    device = "/dev/sda2";
    fsType = "ntfs"; # Specify the file system type
    options = [ "rw" ]; # Mount options 
  };

  # Enabling samba file sharing over local network 
  services.samba = {
    enable = true; # Dont forget to set a password for the user with smbpasswd -a ${user}
    shares = {
      # home = {
      #   "path" = "/home/${user}";
      #   "comment" = "Home Directories";
      #   "browseable" = "yes";
      #   "read only" = "no";
      #   "guest ok" = "yes";
      #   "create mask" = "0644";
      #   "directory mask" = "0755";
      # };
      sda2 = {
        "path" = "/mnt/sda2";
        "comment" = "sda2";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    };
    openFirewall = true;
  };

  swapDevices = [ ];
  zramSwap = {
    enable = true;
    memoryPercent = 10;
    algorithm = "lz4";
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp0s20f0u11u2.useDHCP = lib.mkDefault true;

  # PPPoE configuration for PPPoE connections.
  # networking.interfaces.enp4s0 = {
  #  useDHCP = false;
  #  ipv4.addresses = ["192.168.100.2/24"];
  #  ipv4.gateway = "192.168.100.1";
  #  preUp = "pppoe-start";
  #  postDown = "pppoe-stop";
  # };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkOverride 1 "performance";
  hardware.cpu.intel.updateMicrocode = lib.mkForce config.hardware.enableRedistributableFirmware;
}
