{ lib, config, pkgs, ... }:
let
  cfg = config.kvm;
in
{
  options = {
    kvm = {
      enable = lib.mkEnableOption "Enable KVM";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      qemu
      bridge-utils
      virt-manager
      virt-viewer
      spice
      spice-gtk
      spice-protocol
      win-virtio
      win-spice
      virtiofsd
      virglrenderer
    ];
    # <binary path="/run/current-system/sw/bin/virtiofsd"/> # virtiofsd binary path for virt-manager add this in virt-manager FileSystem Share
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          swtpm.enable = true;
          ovmf.enable = true;
          #ovmf.packages = [ pkgs.OVMFFull ];
        };
        onBoot = "ignore";
        onShutdown = "shutdown";
      };
      spiceUSBRedirection.enable = true;
    };
    services.spice-vdagentd.enable = true;
  };
}

