{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.nm.grub;
in {
  options = {
    nm.grub = {
      enable = lib.mkEnableOption "Enable the GRUB boot loader";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      grub = {
        enable = true;
        # theme = pkgs.sleek-grub-theme.override {
        #   withStyle = "dark";
        #   withBanner = "Yo, sleek operator!";
        # };
        # splashImage = ../public/wallpaper/nixos.png;
        devices = ["nodev"]; # install grub on efi
        efiSupport = true;
        useOSProber = false; # To find Other boot manager like windows
        configurationLimit = 10; # Store number of config
      };
      timeout = 3; # Boot Timeout
    };
  };
}
