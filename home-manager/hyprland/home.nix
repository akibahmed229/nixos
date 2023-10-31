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
  
  #wayland.windowManager.hyprland.enable = true;

  home.file = {
    ".config/hypr" = {
      source = ./others/hypr;
      recursive = true;
    };
    ".config/hypr" = {
      source = ./others/hyprpaper;
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
