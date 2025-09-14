/*
* KVM on Linux: https://sysguides.com/install-kvm-on-linux

* win-11 istallation guide: https://sysguides.com/install-a-windows-11-virtual-machine-on-kvm
* File Share on Window: https://sysguides.com/share-files-between-the-kvm-host-and-windows-guest-using-virtiofs

* KVM Usage Guide: https://sysguides.com/create-virtual-machines-in-kvm-virt-manager
* File Share on Linux: https://sysguides.com/share-files-between-kvm-host-and-linux-guest-using-virtiofs
*/
{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.kvm;
in {
  options = {
    kvm = {
      enable = lib.mkEnableOption "Enable KVM";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      bridge-utils
      guestfs-tools
      virt-manager
      virt-viewer
      spice
      spice-gtk
      spice-protocol
      win-spice
      libvirt
      libvirt-glib
      virtio-win
      virglrenderer
      virtiofsd # <binary path="/run/current-system/sw/bin/virtiofsd"/> # virtiofsd binary path for virt-manager add this in virt-manager FileSystem Share
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
          swtpm.enable = true;
          ovmf = {
            enable = true;
            packages = [
              (pkgs.OVMF.override {
                secureBoot = true;
                tpmSupport = true;
              })
              .fd
            ];
          };
        };
      };
      spiceUSBRedirection.enable = true;
    };
    services = {
      qemuGuest.enable = true;
      spice-vdagentd.enable = true;
      spice-webdavd.enable = true;
    };
  };
}
