{
  self,
  pkgs,
  unstable,
  inputs,
  user,
  lib,
  ...
}: {
  imports =
    ["${inputs.nixos}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"]
    ++ (map self.lib.mkRelativeToRoot [
      "home-manager/hyprland"
      "modules/predefiend/nixos/sops"
    ]);

  grub.enable = lib.mkForce false;
  networking.networkmanager.enable = lib.mkForce false;

  nixpkgs.overlays = [
    self.overlays.nvim-overlay
  ];
  environment.systemPackages = with unstable.${pkgs.system}; [neovim];

  # Enables copy / paste when running in a KVM with spice.
  services.spice-vdagentd.enable = true;
  # Use faster squashfs compression
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  home-manager = {
    useGlobalPkgs = false;
    users.${user} = {
      imports = map self.lib.mkRelativeToRoot [
        "home-manager/home.nix"
        "home-manager/hyprland/home.nix"
      ];
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
