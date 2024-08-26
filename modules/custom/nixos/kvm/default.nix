/*
* win-11 istallation guide: https://sysguides.com/install-a-windows-11-virtual-machine-on-kvm
* KVM on Linux: https://sysguides.com/install-kvm-on-linux
*/
{
  lib,
  config,
  pkgs,
  unstable,
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
    environment.systemPackages = with unstable.${pkgs.system}; [
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

    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          package = unstable.${pkgs.system}.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;
          ovmf = {
            enable = true;
            packages = [
              (unstable.${pkgs.system}.OVMF.override {
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
      spice-vdagentd.enable = true;
      spice-webdavd.enable = true;
    };
  };
}
