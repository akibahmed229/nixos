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

{ config, lib, pkgs, hyprland, theme, ... }:

{
    imports =   
    [(import ../../programs/firefox/firefox.nix)]++
    #[(import ../programs/nvim-nix-video-main/home.nix)]++
    [(import ../../programs/spotify/spicetify.nix)]++
    [(import ../../programs/discord/discord.nix)]++
    [(import ../../programs/lf/lf.nix)];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "discord"
    "spotify"
  ];

  #imports = [(import ./others/hyprutility.nix)];
  wayland.windowManager.hyprland =  {
  enable = true;
  xwayland = { enable = true; };
  settings = {
    # See https://wiki.hyprland.org/Configuring/Keywords/ for more
    "$mod" = "SUPER";
    bind = [
      ## Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
      "$mod, RETURN, exec, alacritty"
      "$mod, Q, killactive,"
      "$mod, M, exit,"
      "$mod, E, exec, thunar"
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
      "$mod, B, exec, firefox"
      "$mod, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"
      # Scroll through existing workspaces with mainMod + scroll
      "$mod, mouse_down, workspace, e+1"
      "$mod, mouse_up, workspace, e-1"
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
     
     bindm = [
      # Move/resize windows with mainMod + LMB/RMB and dragging
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
     ];

     windowrule = [
      # Example windowrule v1
      # windowrule = float, ^(kitty)$
      # Example windowrule v2
      # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
      # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
     ];
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
    ".config//libinput" = {
      source = ./others/libinput;
      recursive = true;
    };
    ".config/gtk-4.0" = {
        source = ../../themes/gtk/${theme};
        recursive = true;
    };
    ".config/gtk-3.0" = {
      source = ../../themes/gtk/${theme};
      recursive = true;
    };
  };
}
