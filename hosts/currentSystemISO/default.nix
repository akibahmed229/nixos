{
  self,
  pkgs,
  unstable,
  inputs,
  user,
  hostname,
  devicename,
  theme,
  state-version,
  lib,
  ...
}: {
  imports =
    ["${inputs.nixos}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"]
    ++ [
      (import ../../home-manager/hyprland)
      (import ../../modules/predefiend/nixos/sops)
    ];

  grub.enable = lib.mkForce false;
  networking.networkmanager.enable = lib.mkForce false;

  # Enables copy / paste when running in a KVM with spice.
  services.spice-vdagentd.enable = true;
  # Use faster squashfs compression
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  home-manager = {
    useGlobalPkgs = false;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs self user hostname devicename theme unstable state-version;};
    users.${user} = {
      imports = [
        (import ../../home-manager/home.nix)
        (import ../../home-manager/hyprland/home.nix)
      ];
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
