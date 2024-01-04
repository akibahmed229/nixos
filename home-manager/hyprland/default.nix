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

{ inputs, config, lib, pkgs, unstable, hyprland, system, ... }:
{
  services ={
    xserver = {
      enable = true;
      layout = "us";
      xkbOptions = "eorsign:e";
      displayManager ={
        sddm.enable = true;
        sddm.theme = "${import ../../pkgs/custompkgs/sddm/sddm.nix {inherit pkgs; }}";
      };
    };
  };

  programs = {
    dconf.enable = true;
    kdeconnect= {
      enable = true;
    };
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
      XDG_CURRENT_DESKTOP="Hyprland";
      XDG_SESSION_TYPE="wayland";
      XDG_SESSION_DESKTOP="Hyprland";
    };
    systemPackages = with pkgs; [
      waybar
      dunst
      #kitty
      wofi
      alacritty
      hyprpaper
      preload
      networkmanagerapplet
      mpd
      xfce.thunar
      # for  qt and gtk
      libsForQt5.polkit-kde-agent
      qt6Packages.qt6ct
      libsForQt5.qt5ct
      libsForQt5.qt5.qtwayland
      qt6.qtwayland
      lxappearance
      nwg-look
      # for clipboard
      cliphist
      wl-clipboard
      # stroge mount
      #udiskie
      ntfs3g
      # sound
      pavucontrol
      # software of gnome of daily usage
      gnome.gnome-software
      gnome.eog
      evince
      gnome.gnome-weather
      rhythmbox
      gnome.gnome-calculator
      gnome.gnome-clocks
      # screen shot
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
    ];
  };
  
  # swaylock config
  security.pam.services.swaylock = {};
  #programs.sway = {
  #  enable = true;
  #  extraPackages = with pkgs; [swaylock-effects];
  #};

  xdg.portal = {                                  # Required for flatpak with window managers and for file browsing
    enable = true;
    extraPortals = with pkgs;[ 
    xdg-desktop-portal-gtk 
    xdg-desktop-portal-wlr
    xdg-desktop-portal-kde
    #xdg-desktop-portal-hyprland
    ];
  };

  # To auto mount usb and other useb devices pluged in 
  services.gvfs.enable = true;
  services.udisks2 = {
    enable = true;
    mountOnMedia = true;
  };

  security.polkit = {
    enable = true;
  };

}
