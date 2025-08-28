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
  hostname,
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkRelativeToRoot;
in {
  imports = map mkRelativeToRoot [
    "home-manager/hyprland"
    "modules/predefiend/nixos/sops"
  ];

  # User management configuration ( custom module ) - see modules/custom/nixos/user
  setUser = {
    name = "${user}";
    usersPath = ./users/.;
    nixosUsers.enable = true;
    homeUsers.enable = true;
    inherit hostname desktopEnvironment state-version;
  };

  # (Custom nixos modules)
  grub.enable = lib.mkForce false;
  networking = {
    hostName = lib.mkDefault hostname;
    wireless.enable = false;
  };

  environment.systemPackages = with pkgs; [neovim cryptsetup spice-vdagent guestfs-tools];

  # Enables copy / paste when running in a KVM with spice.
  services.spice-vdagentd.enable = true;
  services.qemuGuest.enable = true;
  # Use faster squashfs compression
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
}
