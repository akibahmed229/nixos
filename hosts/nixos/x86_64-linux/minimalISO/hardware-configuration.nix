{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = lib.mkForce [
      "btrfs"
      "vfat"
    ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
