#
# KDE Plasma 5 configuration
#
{
  config,
  lib,
  pkgs,
  ...
}: {
  programs = {
    dconf.enable = true;
    kdeconnect = {
      # For GSConnect
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };
  };

  services = {
    xserver = {
      enable = true;

      xkb.layout = "us"; # Keyboard layout & €-sign
      xkb.options = "eurosign:e";
      libinput.enable = true;

      displayManager = {
        sddm.enable = true; # Display Manager
        defaultSession = "plasmawayland"; # Default session
      };

      desktopManager.plasma5 = {
        enable = true; # Desktop Manager
      };
    };
  };

  environment = {
    systemPackages = with pkgs.libsForQt5; [
      # Packages installed
      packagekit-qt
      bismuth
    ];

    plasma5.excludePackages = with pkgs.libsForQt5; [
      elisa
      khelpcenter
      # konsole
      oxygen
    ];
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-kde
  ];
}
