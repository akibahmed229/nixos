# Hyprland system configuration

{ self
, inputs
, config
, lib
, pkgs
, user
, unstable
, hyprland
, system
, ...
}:

{
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
      #cron
      waybar
      dunst
      kitty
      wofi
      preload
      networkmanagerapplet
      ark
      lxmenu-data
      # libsForQt5.polkit-kde-agent
      # mpd
      # For file manager
      xfce.thunar
      xfce.tumbler
      # for  qt and gtk
      qt6.qtwayland
      qt6Packages.qt6ct
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
      gnome.gnome-software
      gnome.eog
      evince
      gnome.gnome-weather
      rhythmbox
      mission-center
      gnome.gnome-calculator
      gnome.gnome-clocks
      # screen shot & other screen tools
      swww
      grim
      slurp
      swappy
      imagemagick
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
      # hypr echoshystem
      hyprpicker
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
    #xdgOpenUsePortal = true; # disable to work default browser 
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

  # services for Hyprland
  services = {
    dbus = {
      implementation = "broker";
      # needed for GNOME services outside of GNOME Desktop
      packages = [ pkgs.gcr ];
    };

    udev = {
      packages = with pkgs; [ gnome.gnome-settings-daemon ];
      extraRules = ''
        # add my android device to adbusers
        SUBSYSTEM=="usb", ATTR{idVendor}=="22d9", MODE="0666", GROUP="adbusers"
      '';
    };

    # Enable cron service
    # Note: *     *    *     *     *          command to run
    #      min  hour  day  month  year        user command
    # cron = {
    #  enable = true;
    #  systemCronJobs = [
    #    ''* * * * * akib     echo "Hello World" >> /home/akib/hello.txt''
    #  ];
    # };

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
