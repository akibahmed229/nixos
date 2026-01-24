/*
* KVM on Linux: https://sysguides.com/install-kvm-on-linux

* win-11 istallation guide: https://sysguides.com/install-windows-11-on-kvm
* File Share on Window: https://sysguides.com/share-files-between-the-kvm-host-and-windows-guest-using-virtiofs

* KVM Usage Guide: https://sysguides.com/create-virtual-machines-in-kvm-virt-manager
* File Share on Linux: https://sysguides.com/share-files-between-kvm-host-and-linux-guest-using-virtiofs
*/
{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nm.kvm;
in {
  options = {
    nm.kvm = {
      enable = mkEnableOption "Enable KVM";

      cpu = mkOption {
        type = types.enum ["amd" "intel"];
        default = "intel";
        description = "Select your CPU type to Correctly Configure KVM";
      };

      bridge = {
        enable = mkEnableOption "Enable Bridge Network on KVM for local network expose.";
        interface = mkOption {
          type = types.str;
          default = "enp4s0";
          description = "Interfaces to use bridge network";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # 1. Essential KVM/QEMU/Libvirt packages and UEFI support
    environment.systemPackages = with pkgs; [
      bridge-utils
      guestfs-tools
      virt-manager
      virt-viewer
      virt-what
      spice
      spice-gtk
      spice-protocol
      win-spice
      libvirt
      libvirt-glib
      virtio-win
      virglrenderer
      edk2
      libosinfo
      virtiofsd # <binary path="/run/current-system/sw/bin/virtiofsd"/> # virtiofsd binary path for virt-manager add this in virt-manager FileSystem Share
      OVMF # UEFI firmware for modern VMs
    ];

    programs.virt-manager.enable = true;

    virtualisation = {
      libvirtd = {
        enable = true;
        onBoot = "ignore";
        onShutdown = "shutdown";
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          vhostUserPackages = with pkgs; [virtiofsd]; # share a folder with a guest,
          swtpm.enable = true; # Correctly enabled for TPM 2.0
        };
      };
      spiceUSBRedirection.enable = true;
    };

    # 2. Networking Configuration for Bridge
    networking = lib.mkIf (cfg.bridge.enable) {
      bridges.br0.interfaces = [cfg.bridge.interface];
      firewall.trustedInterfaces = ["br0"];

      # *** KEY FIX: Assign the IPv4 configuration (DHCP) to the bridge interface itself. ***
      interfaces.br0.useDHCP = true;

      # NOTE: For NetworkManager users, you may need to disable NM for 'enp4s0'
      # by checking if networking.networkmanager.unmanagedInterfaces is relevant,
      # but typically the declarative config overrides NM for the specified interface.
    };

    # 3. Kernel parameters for IOMMU based on CPU type
    boot = {
      kernelParams = [
        (
          # Selects the correct IOMMU driver and enables it
          if cfg.cpu == "intel"
          then "intel_iommu=on"
          else "amd_iommu=on"
        )
        "iommu=pt" # set IOMMU to passthrough mode
        "transparent_hugepage=never"
      ];

      kernel.sysctl = lib.mkDefault {
        "vm.swappiness" = 10;
        "vm.dirty_ratio" = 15;
        "vm.dirty_background_ratio" = 5;
        "kernel.sched_min_granularity_ns" = 10000000;
        "kernel.sched_wakeup_granularity_ns" = 15000000;
      };
    };
  };
}
