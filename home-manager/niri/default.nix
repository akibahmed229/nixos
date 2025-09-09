{pkgs, ...}: let
in {
  services.displayManager.sessionPackages = [
    (pkgs.runCommand "niri-desktop" {
        passthru.providedSessions = ["Niri"];
      } ''
        mkdir -p $out/share/wayland-sessions
        cat > $out/share/wayland-sessions/niri.desktop <<EOF
        [Desktop Entry]
        Name=Niri
        Comment=Wayland session using Niri
        Exec=${pkgs.niri}/bin/niri
        Type=Application
        DesktopNames=Niri
        EOF
      '')
  ];

  # SDDM (custom module)
  sddm.enable = true;

  programs = {
    dconf.enable = true;
    kdeconnect = {
      enable = true;
    };
    seahorse.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      niri
      # 1. System Utilities
      networkmanagerapplet # Network management applet.
      preload # Adaptive readahead daemon to speed up system load times.
      ntfs3g # Read/write driver for NTFS.

      # 2. Desktop Environment & Window Management
      lxmenu-data # Menu data for LXDE desktop.
      qt6.qtwayland # Qt 6 Wayland integration.
      qt6Packages.qt6ct # Qt 6 configuration tool.
      gnome-software # GNOME software manager.
      stacer # Linux system monitoring tool.

      # 3. Multimedia & Audio
      pavucontrol # PulseAudio volume control.
      rhythmbox # Music player.

      # 4. GNOME Applications
      eog # GNOME Eye of GNOME image viewer.
      evince # Document viewer for GNOME.
      gnome-calculator # GNOME calculator.
      gnome-clocks # GNOME clocks application.

      # 5. Hypr Ecosystem & Theming
      hyprpicker # Likely a color picker for the Hypr ecosystem.
      qt6Packages.qtstyleplugin-kvantum # Kvantum style plugin, possibly for theming.
      # qt6Packages.polkit-kde-agent # Polkit agent for KDE (commented out).

      # 6. Archiving Tools
      kdePackages.ark # Archiving tool for KDE (also included in the desktop environment list).

      # 7. Uncategorized or Ambiguous
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
      common.default = ["gtk"];
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
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
    gnome.gnome-keyring.enable = true;
    devmon.enable = true;
    gvfs.enable = true;
    udisks2 = {
      enable = true;
      mountOnMedia = true;
    };
  };

  # Enable GNOME keyring for PAM
  security.pam.services.greetd.enableGnomeKeyring = true;
  # polkit for authentication ( from custom nixos module )
  polkit-gnome.enable = true;
}
