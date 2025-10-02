{pkgs, ...}: {
  # == VM-Specific Settings ==
  # These are crucial for running in QEMU.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda"; # Use the virtual disk.
  fileSystems."/" = {
    device = "/dev/vda";
    fsType = "ext4";
  };
  services.qemuGuest.enable = true; # Improves integration with the host.

  # == Demo Environment Settings ==
  # Configure a graphical desktop and auto-login user.
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

  # Auto-login the 'demo' user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "demo";

  # Create the user account.
  users.users.demo = {
    isNormalUser = true;
    extraGroups = ["wheel"]; # For sudo access.
    password = ""; # No password.
  };

  # Install some fun packages into the VM.
  environment.systemPackages = with pkgs; [
    firefox
    neofetch
  ];

  # Basic system settings.
  networking.hostName = "nixos-vm";
  system.stateVersion = "24.05";
}
