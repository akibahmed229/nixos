# Hyprland system configuration
{
  inputs,
  pkgs,
  self,
  ...
}: let
  inherit (self.lib) mkRelativeToRoot;
in {
  imports = [(mkRelativeToRoot "modules/predefiend/nixos/flatpak")];

  # SDDM (custom module)
  # nm.sddm.enable = true;

  programs = {
    dconf.enable = true;
    kdeconnect = {
      enable = true;
    };
    seahorse.enable = true;
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    # set the flake package
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;
    # make sure to also set the portal package, so that they are in sync
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  environment = {
    systemPackages = with pkgs; [
      # 1. System Utilities
      networkmanagerapplet # Network management applet.
      preload # Adaptive readahead daemon to speed up system load times.
      ntfs3g # Read/write driver for NTFS.

      # 2. Desktop Environment & Window Management
      lxmenu-data # Menu data for LXDE desktop.
      qt6.qtwayland # Qt 6 Wayland integration.
      qt6Packages.qt6ct # Qt 6 configuration tool.
      gnome-software # GNOME software manager.

      # 3. Multimedia & Audio
      pwvucontrol # Pipewire Volume Control.
      rhythmbox # Music player.

      # 4. GNOME Applications
      eog # GNOME Eye of GNOME image viewer.
      evince # Document viewer for GNOME.
      gnome-calculator # GNOME calculator.
      gnome-clocks # GNOME clocks application.
      gnome-calendar # GNOME calender application.

      # 5. Hypr Ecosystem & Theming
      hyprpicker # Likely a color picker for the Hypr ecosystem.
      qt6Packages.qtstyleplugin-kvantum # Kvantum style plugin, possibly for theming.
      nwg-look # Look and feel customization tool.

      # 6. Uncategorized or Ambiguous
      # lxappearance # Tool to manage LXDE themes (commented out).
      # udiskie # Automatic disk mounting tool (commented out).
      # pywal # Tool to generate and set color schemes based on wallpapers (commented out).
      # mpd # Music Player Daemon (commented out).
    ];
  };

  xdg.portal = {
    # Required for flatpak with window managers and for file browsing
    enable = true;
    wlr.enable = true;
    #xdgOpenUsePortal = true; # disable to work default browser
    config = {
      hyprland.default = ["gtk" "hyprland"];
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      #xdg-desktop-portal-wlr
      #xdg-desktop-portal-kde
      #xdg-desktop-portal-hyprland
    ];
  };

  # services for Hyprland
  services = {
    dbus = {
      implementation = "broker";
      # needed for GNOME services outside of GNOME Desktop
      packages = [pkgs.gcr];
    };

    udev = {
      packages = with pkgs; [gnome-settings-daemon];
      extraRules = ''
        # add my android device to adbusers
        SUBSYSTEM=="usb", ATTR{idVendor}=="22d9", MODE="0666", GROUP="adbusers"
      '';
    };

    # To auto mount usb and other useb devices pluged in
    devmon.enable = true;
    gvfs.enable = true;
    udisks2 = {
      enable = true;
      mountOnMedia = true;
    };
  };

  # Enable GNOME keyring for PAM
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  # polkit for authentication ( from custom nixos module )
  nm.myPolkit.enable = true;
}
