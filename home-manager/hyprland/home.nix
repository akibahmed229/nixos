#  Hyprland Home-manager configuration
{
  config,
  pkgs,
  inputs ? {},
  self,
  user,
  ...
}: {
  nixpkgs = {
    # You can add overlays here
    overlays = [
      self.overlays.discord-overlay
      self.overlays.nvim-overlay
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  # Fix: systemd not importing the environment by default.
  wayland.windowManager.hyprland.systemd.variables = ["--all"];

  # imports from the predefiend modules folder
  imports =
    [
      inputs.hyprland.homeManagerModules.default
      {wayland.windowManager.hyprland.systemd.enable = true;}
    ]
    ++ self.lib.mkImport {
      path = ../../modules/predefiend/home-manager;
      ListOfPrograms = ["firefox" "discord" "zsh" "tmux" "lf" "ags" "git"];
    };

  home.packages = with pkgs; [
    self.packages.${pkgs.system}.wallpaper
    xfce.exo
    neovim
    spotify
  ];

  #imports = [(import ./others/hyprutility.nix)];
  wayland.windowManager.hyprland = {
    enable = true;
    plugins = [
      #inputs.hyprland-plugins.packages.${pkgs.system}.hyprtrails
    ];
    xwayland = {enable = true;};
    settings = {
      # See https://wiki.hyprland.org/Configuring/Monitors/
      #monitor=,preferred,auto,auto
      monitor =
        map
        (
          monitor: let
            # set the rmonitor resolution & position from the custom Home-manager module
            resolution = "${toString monitor.width}x${toString monitor.height}@${toString monitor.refreshRate}";
            position = "${toString monitor.x}x${toString monitor.y}";
          in
            # loop through the monitors and set the resolution, position and enable the monitor
            "${monitor.name},${
              if monitor.enabled
              then "${resolution},${position},1"
              else "disable"
            }"
        )
        # set of monitors setting from custom monitor module
        config.monitors;

      # Execute your favorite apps at launch
      exec-once =
        [
          # "waybar"
          # "hyprpaper"
          "ags"
          "swww init"
          "nm-applet --indicator" # simple network manager indicator
          "udiskie &" # USB Mass storage devices mounting
          "wl-paste --type text --watch cliphist store" #Stores only text data
          "wl-paste --type image --watch cliphist store" #Stores only image data
          "kdeconnect-cli --refresh &" # KDE Connect daemon
          "kdeconnect-indicator &"
        ]
        ++ (
          if user == "akib"
          then [
            "openrgb -p ~/.config/OpenRGB/Mobo.orp && openrgb -p ~/.config/OpenRGB/Mouse.orp && openrgb -p ~/.config/OpenRGB/Keyboard.orp " # Loads my RGB light
            # app that i want to start after login
            # "discord"
            "firefox"
            "spotify"
            "vesktop"
            #"alacritty"
            "kitty"
          ]
          else []
        );

      # See https://wiki.hyprland.org/Configuring/Keywords/ for more
      "$mod" = "SUPER";
      bind =
        [
          ## Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
          "$mod, RETURN, exec, kitty"
          "$mod, Q, killactive,"
          "$mod, DELETE, exit,"
          "$mod, E, exec, thunar"
          "$mod, T, togglefloating,"
          "$mod, F, fullscreen"
          # ''$mod, R, exec, wofi -n --show drun -p "Run App"''
          ''$mod, D, exec, emacsclient -c -a "emacs"''
          "$mod, R, exec, ags -t applauncher"
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

      windowrule =
        [
          # Example windowrule v1
          # windowrule = float, ^(kitty)$
          # Example windowrule v2
          # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
          # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more

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
        ]
        ++ (
          if user == "akib"
          then [
            # Window open rule
            #"workspace 1,Alacritty"
            "workspace 1,kitty"
            "workspace 2,firefox"
            # "workspace 3,discord"
            "workspace 3,vesktop"
            "workspace 4,Spotify"
            "workspace 5,virt-manager"
          ]
          else []
        );
    };

    extraConfig = builtins.readFile ./others/hypr/hyprland.conf;
  };

  home.file = {
    #".config/hypr/hyprpaper.conf" = {
    #  source = ./others/hypr/hyprpaper.conf;
    #  recursive = true;
    #};
    #".config/dunst" = {
    #  source = ./others/dunst;
    #  recursive = true;
    #};
    ".config/waybar" = {
      source = ./others/waybar;
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
    ".config/Thunar" = {
      source = ./others/Thunar;
      recursive = true;
    };
  };

  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
  };
}
