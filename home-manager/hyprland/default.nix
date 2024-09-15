# Hyprland system configuration
{
  inputs,
  pkgs,
  unstable,
  ...
}: {
  # SDDM (custom module)
  sddm.enable = true;

  programs = {
    dconf.enable = true;
    kdeconnect = {
      enable = true;
    };
    seahorse.enable = true;
  };

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;
  };

  # using mesa drivers from  Hyprland's nixpkgs
  hardware.opengl = let
    pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  in {
    package = pkgs-unstable.mesa.drivers;

    # if you also want 32-bit support (e.g for Steam)
    driSupport32Bit = true;
    package32 = pkgs-unstable.pkgsi686Linux.mesa.drivers;
  };

  environment = {
    variables = {
      #WLR_NO_HARDWARE_CURSORS="1";         # Possible variables needed in vm
      #WLR_RENDERER_ALLOW_SOFTWARE="1";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "Hyprland";
    };

    systemPackages = with pkgs;
      [
        # 1. System Utilities
        networkmanagerapplet # Network management applet.
        preload # Adaptive readahead daemon to speed up system load times.
        ntfs3g # Read/write driver for NTFS.

        # 2. Desktop Environment & Window Management
        lxmenu-data # Menu data for LXDE desktop.
        qt6.qtwayland # Qt 6 Wayland integration.
        qt6Packages.qt6ct # Qt 6 configuration tool.
        libsForQt5.qt5ct # Qt 5 configuration tool.
        libsForQt5.qt5.qtwayland # Qt 5 Wayland integration.
        libsForQt5.ark.out # Ark for Qt 5 (possibly a file manager or archiver).
        gnome.gnome-software # GNOME software manager.
        stacer # Linux system monitoring tool.
        libsForQt5.qt5.qtquickcontrols2 # Qt Quick Controls 2 for Qt 5.
        libsForQt5.qt5.qtgraphicaleffects # Graphical effects for Qt 5.

        # 3. Multimedia & Audio
        pavucontrol # PulseAudio volume control.
        rhythmbox # Music player.

        # 4. GNOME Applications
        gnome.eog # GNOME Eye of GNOME image viewer.
        evince # Document viewer for GNOME.
        gnome.gnome-calculator # GNOME calculator.
        gnome.gnome-clocks # GNOME clocks application.

        # 5. Hypr Ecosystem & Theming
        hyprpicker # Likely a color picker for the Hypr ecosystem.
        libsForQt5.qtstyleplugin-kvantum # Kvantum style plugin, possibly for theming.
        # libsForQt5.polkit-kde-agent # Polkit agent for KDE (commented out).

        # 6. Archiving Tools
        ark # Archiving tool for KDE (also included in the desktop environment list).

        # 7. Uncategorized or Ambiguous
        # lxappearance # Tool to manage LXDE themes (commented out).
        # udiskie # Automatic disk mounting tool (commented out).
        # pywal # Tool to generate and set color schemes based on wallpapers (commented out).
        # mpd # Music Player Daemon (commented out).
      ]
      ++ (with unstable.${pkgs.system}; [
        swaylock # Screen locker for Wayland.
        swaylock-effects # Enhanced screen locker with effects for Wayland.
      ]);
  };

  # swaylock config for Hyprland lockscreen
  security.pam.services.swaylock = {};

  xdg.portal = {
    # Required for flatpak with window managers and for file browsing
    enable = true;
    wlr.enable = true;
    #xdgOpenUsePortal = true; # disable to work default browser
    config = {
      common.default = ["gtk"];
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
      packages = with pkgs; [gnome.gnome-settings-daemon];
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
