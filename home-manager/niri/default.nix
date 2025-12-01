{
  pkgs,
  config,
  ...
}: {
  # SDDM (custom module)
  # nm.sddm.enable = true;

  programs = {
    niri = {
      enable = true;
      package = pkgs.niri;
    };
    dconf.enable = true;
    kdeconnect = {
      enable = true;
    };
    seahorse.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      # 1. System Utilities
      networkmanagerapplet # Network management applet.
      ntfs3g # Read/write driver for NTFS.

      # 2. Desktop Environment & Window Management
      lxmenu-data # Menu data for LXDE desktop.
      qt6.qtwayland # Qt 6 Wayland integration.
      qt6Packages.qt6ct # Qt 6 configuration tool.
      gnome-software # GNOME software manager.

      # 3. Multimedia & Audio
      pwvucontrol # Pipewire volume control.
      rhythmbox # Music player.

      # 4. GNOME Applications
      eog # GNOME Eye of GNOME image viewer.
      evince # Document viewer for GNOME.
      gnome-calculator # GNOME calculator.
      gnome-clocks # GNOME clocks application.
      gnome-calendar # GNOME calender application.

      # 5. Theming
      qt6Packages.qtstyleplugin-kvantum # Kvantum style plugin, possibly for theming.
      nwg-look # Look and feel customization tool.
    ];
  };

  xdg.portal = {
    # Required for flatpak with window managers and for file browsing
    enable = true;
    wlr.enable = true;
    # xdgOpenUsePortal = true; # disable to work default browser
    config = {
      common = {
        default = ["gnome" "gtk"];
      };
      niri = {
        # Niri-specific section to assign portals properly
        default = ["gtk" "gnome"];
        "org.freedesktop.impl.portal.ScreenCast" = "gnome";
        "org.freedesktop.impl.portal.RemoteDesktop" = "gnome";
        "org.freedesktop.impl.portal.Screenshot" = "gnome";
      };
    };
    configPackages = [config.programs.niri.package];
    extraPortals = with pkgs; [
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      xdg-desktop-portal-wlr # Explicitly add for fallback if needed
    ];
  };

  # services for Niri
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

  # Disable PulseAudio if PipeWire is enabled
  services.pulseaudio.enable = false;

  # Enable Gnome keyring for PAM
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  # polkit for authentication ( from custom nixos module )
  nm.myPolkit.enable = true;
}
