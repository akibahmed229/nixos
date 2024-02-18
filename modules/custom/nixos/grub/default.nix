{ lib, config, pkgs, ... }:
let
  cfg = config.grub;
in
{
  options = {
    grub = {
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
        theme = pkgs.sleek-grub-theme.override { withStyle = "dark"; withBanner = "Yo, sleek operator!"; };
        # splashImage = ../public/wallpaper/nixos.png;
        devices = [ "nodev" ]; # install grub on efi
        efiSupport = true;
        useOSProber = true; # To find Other boot manager like windows 
        configurationLimit = 5; # Store number of config 
      };
      timeout = 3; # Boot Timeout
    };
  };
}

