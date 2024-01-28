#
#  Hyprland configuration
#
#  flake.nix
#   ├─ ./hosts
#   │   └─ ./<host>
#   │       └─ default.nix
#   └─ ./modules
#       └─ ./desktop
#           └─ ./hyprland
#               └─ default.nix *
#

{ inputs
, config
, lib
, pkgs
, unstable
, hyprland
, system
, ...
}:

{
  services = {
    xserver = {
      enable = true;
      layout = "us";
      xkbOptions = "eorsign:e";
      displayManager = {
        sddm.enable = true;
        sddm.theme = "${pkgs.callPackage ../../pkgs/sddm/sddm.nix { }}";
      };
    };
  };

  programs = {
    dconf.enable = true;
    kdeconnect = {
      enable = true;
    };
    seahorse.enable = true;
  };

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
  };

  environment = {
    variables = {
      #WLR_NO_HARDWARE_CURSORS="1";         # Possible variables needed in vm
      #WLR_RENDERER_ALLOW_SOFTWARE="1";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "Hyprland";
    };

    systemPackages = with pkgs; [
      waybar
      dunst
      kitty
      wofi
      alacritty
      hyprpaper
      preload
      networkmanagerapplet
      ark
      # libsForQt5.polkit-kde-agent
      # mpd
      # For file manager
      xfce.thunar
      xfce.tumbler
      # for  qt and gtk
      #qt6Packages.qt6ct
      libsForQt5.qt5ct
      libsForQt5.qt5.qtwayland
      libsForQt5.qtstyleplugin-kvantum
      libsForQt5.ark.out
      #qt6.qtwayland
      #lxappearance
      nwg-look
      # for clipboard
      cliphist
      wl-clipboard
      # stroge mount
      #udiskie
      ntfs3g
      # sound
      pavucontrol
      # software of gnome for daily usage
      gnome.eog
      evince
      gnome.gnome-weather
      rhythmbox
      mission-center
      gnome.gnome-calculator
      gnome.gnome-clocks
      # screen shot & other screen tools
      grim
      slurp
      swappy
      imagemagick
      xwaylandvideobridge
      # Screen  lock 
      wlogout
      swaylock-effects
      swaylock
      # fot sddm theme 
      libsForQt5.qt5.qtquickcontrols2
      libsForQt5.qt5.qtgraphicaleffects
      # for music
      playerctl
      # color grab 
      #pywal
    ];
  };

  # swaylock config
  security.pam.services.swaylock = { };
  #programs.sway = {
  #  enable = true;
  #  extraPackages = with pkgs; [swaylock-effects];
  #};

  xdg.portal = {
    # Required for flatpak with window managers and for file browsing
    enable = true;
    wlr.enable = true;
    xdgOpenUsePortal = true;
    config = {
      common.default = [ "gtk" ];
      hyprland.default = [ "gtk" "hyprland" ];
    };
    extraPortals = with pkgs;[
      xdg-desktop-portal-gtk
      #xdg-desktop-portal-wlr
      #xdg-desktop-portal-kde
      #xdg-desktop-portal-hyprland
    ];
  };

  services.dbus = {
    implementation = "broker";
    # needed for GNOME services outside of GNOME Desktop
    packages = [ pkgs.gcr ];
  };

  services.udev = {
    packages = with pkgs; [ gnome.gnome-settings-daemon ];
    extraRules = ''
      # add my android device to adbusers
      SUBSYSTEM=="usb", ATTR{idVendor}=="22d9", MODE="0666", GROUP="adbusers"
    '';
  };

  # To auto mount usb and other useb devices pluged in 
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2 = {
    enable = true;
    mountOnMedia = true;
  };

  # polkit for authentication
  security.polkit = {
    enable = true;
  };

  # A dbus session bus service that is used to bring up authentication dialogs used by polkit and gnome-keyring 
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}
