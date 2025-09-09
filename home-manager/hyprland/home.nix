#  Hyprland Home-manager configuration
{
  config,
  pkgs,
  inputs ? {},
  self,
  user,
  ...
}: {
  # imports = [(import ./others/hyprutility.nix)];
  # imports hyprland home-manager modules
  imports = [
    inputs.hyprland.homeManagerModules.default
    {wayland.windowManager.hyprland.systemd.enable = false;}
  ];

  home.packages = with pkgs; [
    # 1. Desktop Environment & Customization
    self.packages.${pkgs.system}.wallpaper # Wallpaper management tool.
    nwg-look # Look and feel customization tool.
    # Theme engine for Qt.
    qt6Packages.qtstyleplugin-kvantum
    brightnessctl # Brightness control tool.
    ddcutil # Control the settings of connected displays via DDC/CI.

    swww # Sway wallpaper manager.

    # 2. Multimedia & Audio
    playerctl # Music player controller.

    # 3. Screenshot & Screen Tools
    self.packages.${pkgs.system}.wallpaper
    self.packages.${pkgs.system}.screenshot # Screenshot tool.
    imagemagick # Image manipulation tool, often used for screenshots.
    self.packages.${pkgs.system}.custom_nsxiv # Image viewer.

    # 4. Clipboard Management
    cliphist # Clipboard history management tool.
    wl-clipboard # Wayland clipboard tool.
  ];

  # Fix: systemd not importing the environment by default.
  # wayland.windowManager.hyprland.systemd.variables = ["--all"];
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
          # "ags run"
          "swww-daemon"
          "nm-applet --indicator" # simple network manager indicator
          "udiskie &" # USB Mass storage devices mounting
          "wl-paste --type text --watch cliphist store" #Stores only text data
          "wl-paste --type image --watch cliphist store" #Stores only image data
          "kdeconnect-cli --refresh &" # KDE Connect daemon
          "kdeconnect-indicator &"
        ]
        ++ (
          if config.home.username == "akib"
          then [
            "openrgb -p ~/.config/OpenRGB/Mobo.orp && openrgb -p ~/.config/OpenRGB/Mouse.orp && openrgb -p ~/.config/OpenRGB/Keyboard.orp" # Loads my RGB light
            # app that i want to start after login
            # "discord"
            "firefox"
            "spotify"
            "vesktop"
            #"alacritty"
            "kitty"
          ]
          else [
            "thunar"
            "firefox"
          ]
        );

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 3;
        layout = "dwindle";
        # col = {
        #   active_border = lib.mkForce "rgb(${toString config.stylix.base16Scheme.base0E})";
        #   inactive_border = lib.mkForce "rgb(${toString config.stylix.base16Scheme.base00})";
        # };
      };

      env = [
        # Toolkit Backend Variables
        "GDK_BACKEND,wayland,x11,*" # GTK: Use wayland if available. If not: try x11, then any other GDK backend.
        "QT_QPA_PLATFORM,wayland;xcb" # Qt: Use wayland if available, fall back to x11 if not.
        "SDL_VIDEODRIVER,wayland" # Run SDL2 applications on Wayland. Remove or set to x11 if games that provide older versions of SDL cause compatibility issues
        "CLUTTER_BACKEND,wayland" # Clutter package already has wayland enabled, this variable will force Clutter applications to try and use the Wayland backend

        # XDG Specifications
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"

        # Qt Variables
        # https://doc.qt.io/qt-5/highdpi.html
        "QT_QPA_PLATFORMTHEME,qt5ct" # Tells Qt based applications to pick your theme from qt5ct,gtk use with Kvantum.
        "QT_QPA_PLATFORM,wayland;xcb" # Tell Qt applications to use the Wayland backend, and fall back to x11 if Wayland is unavailable
        "QT_AUTO_SCREEN_SCALE_FACTOR,1" # enables automatic scaling, based on the monitor’s pixel density
        # "QT_WAYLAND_DISABLE_WINDOWDECORATION,1" # Disables window decorations on Qt applications

        # Not all apps support running natively on Wayland. To work around this, XWayland should be enabled.
        "NIXOS_OZONE_WL,1"

        "systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      ];

      # See https://wiki.hyprland.org/Configuring/Keywords/ for more
      "$mod" = "SUPER";
      bind =
        [
          ## Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
          "$mod, RETURN, exec, kitty"
          "$mod, Q, killactive,"
          "$mod, DELETE, exit,"
          "${
            if !config.programs.yazi.enable # NOTE: thunar is currently in used
            then "$mod, E, exec, kitty -e yazi"
            else "$mod, E, exec, thunar"
          }"
          "$mod, T, togglefloating,"
          "$mod, F, fullscreen"
          # ''$mod, R, exec, wofi -n --show drun -p "Run App"''
          # "$mod, R, exec, ags toggle launcher -i app"
          "$mod, R, exec, wofi"
          ''$mod, D, exec, emacsclient -c -a "emacs"''
          "$mod, P, pseudo," # dwindle
          "$mod ALT, J, togglesplit," # dwindle
          "$mod, B, exec, firefox"
          ''$mod, V, exec, cliphist list | wofi -n --dmenu -p "Copy Text" | cliphist decode | wl-copy''
          "$mod, Print, exec, screenshot" # from my pkgs shellscript
          "$mod, W, exec, wallpaper" # from my pkgs shellscript
          "$mod ALT, L, exec, quickshell -p ~/.config/quickshell/Modules/LockScreen/shell.qml"
          # "$mod SHIFT, DELETE, exec, quickshell -p ~/.config/quickshell/Modules/Wlogout/WLogoutShell.qml"

          # Move focus with mainMod + ctrl + (h,j,k,l) keys
          "$mod CTRL, h, movefocus, l"
          "$mod CTRL, l, movefocus, r"
          "$mod CTRL, k, movefocus, u"
          "$mod CTRL, j, movefocus, d"
          # Scroll through existing workspaces with mainMod + scroll
          "$modCONTROL, right, workspace, e+1"
          "$modCONTROL, left, workspace, e-1"
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
          "ALT, Tab, cyclenext"
          "ALT, Tab, bringactivetotop"
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
          builtins.concatLists (builtins.genList (
              i: let
                ws = i + 1;
              in [
                "$mod, code:1${toString i}, workspace, ${toString ws}"
                "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
              ]
            )
            10)
        );

      # These binds set the expected behavior for regular keyboard media volume keys, including when the screen is locked:
      bindel = [
        " , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        " , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        " , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];
      bindl = [
        # Requires playerctl
        " , XF86AudioPlay, exec, playerctl play-pause"
        " , XF86AudioPrev, exec, playerctl previous"
        " , XF86AudioNext, exec, playerctl next"

        # Requires ddcutil
        " , XF86MonBrightnessUp, exec,  ddcutil --display 1 setvcp 10 + 5"
        " , XF86MonBrightnessDown, exec,  ddcutil --display 1 setvcp 10 + 5"
      ];

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
          "opacity 1.0 override 0.9 override,class:.virt-manager-wrapped"
          "opacity 1.0 override 0.9 override,class:vlc"
          "opacity 1.0 override 0.9 override,class:steam"

          # Floating window rule
          "float,class:org.pulseaudio.pavucontrol, title:Volume Control"
          "float,class:blueman-manager, title:blueman-manager"
          "float,class:nm-connection-editor, title:Network Connections"
          "float,class:openrgb, title:OpenRGB"
        ]
        ++ (
          if user == "akib"
          then [
            # Window open rule
            #"workspace 1,Alacritty"
            "workspace 1,class:kitty"
            "workspace 2,class:firefox"
            # "workspace 3,discord"
            "workspace 3,class:vesktop"
            "workspace 4,class:spotify"
            "workspace 5,class:.virt-manager-wrapped"
          ]
          else []
        );
    };

    extraConfig = builtins.readFile ./hypr/hyprland.conf;
  };

  # programs.hyprlock = {
  #   enable = true;
  #   package = pkgs.hyprlock;
  #   extraConfig = builtins.readFile ./hyprlock/hyprlock.conf;
  # };

  services = {
    # For auto mounting USB devices
    udiskie = {
      enable = true;
      automount = true;
      notify = true;
    };

    # Hyprland's idle daemon
    hypridle = {
      enable = true;
      package = pkgs.hypridle;
      settings = {
        general = {
          # lock_cmd = "pidof hyprlock || hyprlock"; # avoid starting multiple hyprlock instances.
          before_sleep_cmd = "loginctl lock-session"; # lock before suspend.
          after_sleep_cmd = "hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
        };
        listener = [
          {
            timeout = 60 * 60; # 1 hour.
            on-timeout = "quickshell -p ~/.config/quickshell/Modules/LockScreen/shell.qml"; # lock the screen after inactivity.
          }
        ];
      };
    };
  };
}
