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
        gdm.enable = true;
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
      # for theming qt and gtk
      qt6Packages.qt6ct
      qt6.qtwayland
      lxappearance
      nwg-look
      # for clipboard
      cliphist
      wl-clipboard
      # stroge mount
      udiskie
      ntfs3g
      # sound
      pavucontrol
    ];
  };

  xdg.portal = {                                  # Required for flatpak with window managers and for file browsing
    enable = true;
    extraPortals = with pkgs;[ 
    xdg-desktop-portal-gtk 
    xdg-desktop-portal-wlr
    xdg-desktop-portal-kde
    #xdg-desktop-portal-hyprland
    ];
  };

  services.udisks2 = {
    enable = true;
    mountOnMedia = true;
  };

  security.polkit = {
    enable = true;
  };

}
