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
let
  exec = "exec Hyprland";
in
{
  programs.hyprland = {
    enable = true;  
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
  };

  environment = {
    #loginShellInit = ''
    #  if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
    #    ${exec}
    #  fi
    #'';                                   # Will automatically open Hyprland when logged into tty1

   # variables = {
   #   #WLR_NO_HARDWARE_CURSORS="1";         # Possible variables needed in vm
   #   #WLR_RENDERER_ALLOW_SOFTWARE="1";
   #   XDG_CURRENT_DESKTOP="Hyprland";
   #   XDG_SESSION_TYPE="wayland";
   #   XDG_SESSION_DESKTOP="Hyprland";
   # };
    systemPackages = with pkgs; [
      waybar
      dunst
      wl-clipboard
      kitty
      wofi
      alacritty
    ];
  };

  xdg.portal = {                                  # Required for flatpak with window managers and for file browsing
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
