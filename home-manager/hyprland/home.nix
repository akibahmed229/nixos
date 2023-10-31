#
#  Hyprland Home-manager configuration
#
#  flake.nix
#   ├─ ./hosts
#   │   └─ ./<host>
#   │       └─ home.nix
#   └─ ./modules
#       └─ ./desktop
#           └─ ./hyprland
#               └─ home.nix *
#

{ config, lib, pkgs, ... }:

{
  #imports = [(import ./others/hyprutility.nix)];
  

  xdg.configFile."hypr/hyprland.conf".source = ./others/hypr/hyprland.conf;
  #wayland.windowManager.hyprland.enable = true;
  home.file = {
    ".config/hypr" = {
      source = ./others/hypr/hyprpaper.conf;
      recursive = true;
    };
    ".config/waybar" = {
      source = ./others/waybar;
      recursive = true;
    };
    ".config/dunst" = {
      source = ./others/dunst;
      recursive = true;
    };
  };
}
