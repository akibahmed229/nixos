#  Hyprland Home-manager configuration

#  flake.nix
#   ├─ ./hosts
#   │   └─ ./<host>
#   │       └─ home.nix
#   └─ ./modules
#       └─ ./desktop
#           └─ ./hyprland
#               └─ home.nix *
#

{ config
, lib
, pkgs
, hyprland
, inputs ? { }
, theme
, ...
}:

{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "discord"
    "spotify"
  ];

  imports =
    [ (import ../../modules/predefiend/home-manager/firefox/firefox.nix) ] ++
    [ (import ../../modules/predefiend/home-manager/spotify/spicetify.nix) ] ++
    [ (import ../../modules/predefiend/home-manager/discord/discord.nix) ] ++
    [ (import ../../modules/predefiend/home-manager/zsh/zsh.nix) ] ++
    [ (import ../../modules/predefiend/home-manager/tmux/tmux.nix) ] ++
    [ (import ../../modules/predefiend/home-manager/lf/lf.nix) ];

  home.packages = with pkgs; [
    (import ./others/swww/wallpaper.nix {inherit pkgs; })
  ];

  #imports = [(import ./others/hyprutility.nix)];
  wayland.windowManager.hyprland = {
    enable = true;
    plugins = [
      #inputs.hyprland-plugins.packages.${pkgs.system}.hyprtrails
    ];
    xwayland = { enable = true; };
    settings = {
      # See https://wiki.hyprland.org/Configuring/Monitors/
      #monitor=,preferred,auto,auto 
      monitor = [
        ",1920x1080@75,auto,1"
      ];

      # Execute your favorite apps at launch
      exec-once = [
        "waybar"
        #"hyprpaper"
        "swww init"
        "nm-applet --indicator" # simple network manager indicator
        "udiskie &" # USB Mass storage devices mounting
        "wl-paste --type text --watch cliphist store" #Stores only text data
        "wl-paste --type image --watch cliphist store" #Stores only image data
        "openrgb -p ~/.config/OpenRGB/Mobo.orp && openrgb -p ~/.config/OpenRGB/Mouse.orp && openrgb -p ~/.config/OpenRGB/Keyboard.orp " # Loads my RGB light
        "kdeconnect-cli --refresh &" # KDE Connect daemon 
        "kdeconnect-indicator &"

        ## app that i want to start after login
        "discord"
        "firefox"
        "spotify"
        "alacritty"
      ];

      # See https://wiki.hyprland.org/Configuring/Keywords/ for more
      "$mod" = "SUPER";
      bind = [
        ## Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
        "$mod, RETURN, exec, alacritty"
        "$mod, Q, killactive,"
        "$mod, DELETE, exit,"
        "$mod, E, exec, thunar"
        "$mod, T, togglefloating,"
        "$mod, F, fullscreen"
        ''$mod, R, exec, wofi -n --show drun -p "Run App"''
        "$mod, P, pseudo," # dwindle
        "$mod ALT, J, togglesplit," # dwindle
        "$mod, B, exec, firefox"
        ''$mod, V, exec, cliphist list | wofi -n --dmenu -p "Copy Text" | cliphist decode | wl-copy''
        ''$mod, Print, exec, grim -g "$(slurp)" - | swappy -f -''
        "$mod, W, exec, wallpaper"
        "$mod ALT, L, exec, swaylock"
        "$mod SHIFT, DELETE, exec, wlogout"

        # Move focus with mainMod + ctrl + (h,j,k,l) keys
        "$mod CTRL, h, movefocus, l"
        "$mod CTRL, l, movefocus, r"
        "$mod CTRL, k, movefocus, u"
        "$mod CTRL, j, movefocus, d"
        # Scroll through existing workspaces with mainMod + scroll
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"

        # window 
        "$mod SHIFT, l, resizeactive, 100 0"
        "$mod SHIFT, h, resizeactive, -100 0"
        "$mod SHIFT, k, resizeactive, 0 -100"
        "$mod SHIFT, j, resizeactive, 0 100"
        "$mod, l, movewindow, r"
        "$mod, h, movewindow, l"
        "$mod, k, movewindow, u"
        "$mod, j, movewindow, d"

      ]
      ++ (
        # workspaces
        # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
        builtins.concatLists (builtins.genList
          (
            x:
            let
              ws =
                let
                  c = (x + 1) / 10;
                in
                builtins.toString (x + 1 - (c * 10));
            in
            [
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

        # Window open rule
        "workspace 1,Alacritty"
        "workspace 2,firefox"
        "workspace 3,discord"
        "workspace 4,Spotify"
        "workspace 5,virt-manager"

        # Window opacity rule
        #"opacity 1.0 override 0.9 override,^(firefox)$"
        #"opacity 1.0 override 0.9 override,^(virt-manager)$"
        "opacity 1.0 override 0.9 override,^(vlc)$"
        #"opacity 1.0 override 0.9 override,^(steam)$"

        # Floating window rule
        "float,^(pavucontrol)$"
        "float,^(blueman-manager)$"
        "float,^(nm-connection-editor)$"
        "float,^(openrgb)$"

      ];
    };

    extraConfig = builtins.readFile ./others/hypr/hyprland.conf;
  };

  home.file = {
    #".config/hypr/hyprpaper.conf" = {
    #  source = ./others/hypr/hyprpaper.conf;
    #  recursive = true;
    #};
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
    ".config/wlogout" = {
      source = ./others/wlogout;
      recursive = true;
    };
    ".config/swaylock" = {
      source = ./others/swaylock;
      recursive = true;
    };
    ".config/swappy" = {
      source = ./others/swappy;
      recursive = true;
    };
    ".config//libinput" = {
      source = ./others/libinput;
      recursive = true;
    };
    ".config/Thunar/thunarrc" = {
      source = ./others/Thunar/thunarrc;
      recursive = true;
    };
    ".config/gtk-4.0" = {
      source = ../../public/themes/gtk/${theme};
      recursive = true;
    };
    ".config/gtk-3.0" = {
      source = ../../public/themes/gtk/${theme};
      recursive = true;
    };
  };

  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
  };
}
