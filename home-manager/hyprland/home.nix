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

{ config, lib, pkgs, hyprland, ... }:

{
  #imports = [(import ./others/hyprutility.nix)];
  wayland.windowManager.hyprland =  {
  enable = true;
  xwayland = { enable = true; };
  settings = {
    "$mod" = "SUPER";
    bind =
      [
     "$mod, RETURN, exec, alacritty"
     "$mod, Q, killactive,"
     "$mod, M, exit,"
     "$mod, E, exec, dolphin"
     "$mod, T, togglefloating,"
     "$mod, F, fullscreen"
     "$mod, W, exec, wofi --show drun"
     "$mod, P, pseudo, # dwindle"
     "$mod, J, togglesplit, # dwindle"
    
      # Move focus with mainMod + arrow keys
      "$mod, left, movefocus, l"
      "$mod, right, movefocus, r"
      "$mod, up, movefocus, u"
      "$mod, down, movefocus, d"
      "$mod, F, exec, firefox"
      ", Print, exec, grimblast copy area"
      ]
        ++ (
        # workspaces
        # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
        builtins.concatLists (builtins.genList (
            x: let
              ws = let
                c = (x + 1) / 10;
              in
                builtins.toString (x + 1 - (c * 10));
            in [
              "$mod, ${ws}, workspace, ${toString (x + 1)}"
              "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
            ]
          )
          10)
      );
  };

  extraConfig = builtins.readFile ./others/hyprland/hyprland.conf;
  };

  home.file = {
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
    ".config/wofi" = {
      source = ./others/wofi;
      recursive = true;
    };
  };
}
