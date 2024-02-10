#
# Gnome configuration
#

{ config, lib, pkgs, unstable, ... }:

{
  programs = {
    dconf.enable = true;
    kdeconnect = {
      # For GSConnect
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };
  };

    i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with unstable; [
      (ibus-engines.typing-booster.override { langs = [ "en_US" ]; })
    ];
  };

  services = {
    xserver = {
      enable = true;

      layout = "us"; # Keyboard layout & €-sign
      xkbOptions = "eurosign:e";
      libinput.enable = true;

      displayManager.gdm.enable = true; # Display Manager 
      desktopManager.gnome.enable = true; # Window Manager
    };
    udev.packages = with pkgs; [
      gnome.gnome-settings-daemon
    ];
  };

  services.xserver.displayManager.gdm.settings = {
    greeter = {
      # Hide root user
      IncludeAll = false;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      # Packages installed
      unstable.gnome.dconf-editor
      unstable.gnome.gnome-tweaks
      unstable.gnome.adwaita-icon-theme
      gnome-menus
      xorg.xkill
      xorg.libX11
      xorg.libX11.dev
      xorg.libxcb
      xorg.libXft
      xorg.libXinerama
      xorg.xinit
    ];
    gnome.excludePackages = (with pkgs; [
      # Gnome ignored packages
      gnome-tour
    ]) ++ (with pkgs.gnome; [
      gedit
      epiphany
      geary
      gnome-characters
      tali
      iagno
      hitori
      atomix
      yelp
      gnome-contacts
      gnome-initial-setup
    ]);
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gnome
  ];
}
