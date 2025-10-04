# `nix build .#nixosConfigurations.currentSystemISO.config.system.build.isoImage` - from nix-config directory to generate the iso manually
#
# Generated images will be output to the ~/nix-config/results directory unless drive is specified
{
  self,
  pkgs,
  user,
  lib,
  desktopEnvironment,
  state-version,
  system,
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkRelativeToRoot;
in {
  imports = map mkRelativeToRoot [
    "home-manager/${desktopEnvironment}"
    "home-manager/niri"
  ];

  # Custom nixos modules
  nm = {
    # User management configuration - see modules/custom/nixos/user
    setUser = {
      name = user;
      usersPath = ./users/.;
      nixosUsers.enable = true;
      homeUsers.enable = true;

      system = {
        inherit (system) path name;
        inherit desktopEnvironment state-version;
      };
    };
  };

  # (Custom nixos modules)
  nm.grub.enable = lib.mkForce false;
  networking = {
    wireless.enable = false;
  };

  environment.systemPackages = with pkgs; [neovim cryptsetup spice-vdagent guestfs-tools];

  # Enables copy / paste when running in a KVM with spice.
  services.spice-vdagentd.enable = true;
  services.qemuGuest.enable = true;
  # Use faster squashfs compression
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
}
