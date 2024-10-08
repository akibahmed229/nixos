/*
# Gnome Home-Manager Configuration
#
# Dconf settings can be found by running "$ dconf watch /"
*/
{
  lib,
  pkgs,
  theme,
  self,
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkImport mkRelativeToRoot;
in {
  imports = mkImport {
    path = mkRelativeToRoot "modules/predefiend/home-manager";
    ListOfPrograms = ["firefox" "spicetify" "discord" "zsh" "tmux" "lf"];
  };

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "spotify"
    ];

  dconf.settings = {
    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "Alacritty.desktop"
        "code.desktop"
        "android-studio.desktop"
        "discord.desktop"
        "com.github.eneshecan.WhatsAppForLinux.desktop"
        "spotify.desktop"
        "steam.desktop"
        "org.gnome.Nautilus.desktop"
        "org.gnome.Software.desktop"
      ];
      disable-user-extensions = false;
      enabled-extensions = [
        "blur-my-shell@aunetx"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        # "apps-menu@gnome-shell-extensions.gcampax.github.com"
        # "drive-menu@gnome-shell-extensions.gcampax.github.com"
        #"dash-to-panel@jderose9.github.com"
        #"dash-to-dock@micxgx.gmail.com"             # Dash to panel alternative
        "caffeine@patapon.info"
        "clipboard-indicator@tudmotu.com"
        # "bluetooth-quick-connect@bjarosze.gmail.com"
        "rounded-window-corners@yilozt"
        #"space-bar@luchrioh"
        # "CoverflowAltTab@palatis.blogspot.com"
        "gsconnect@andyholmes.github.io"
        "forge@jmmaranan.com"
        "Vitals@CoreCoding.com"
        "quick-settings-avatar@d-go"
        #"quick-settings-tweaks@qwreey"
        "gnome-ui-tune@itstime.tech"
        #"custom-hot-corners-extended@G-dH.github.com"
        "impatience@gfxmonk.net"
        "burn-my-windows@schneegans.github.com"
        "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
        "native-window-placement@gnome-shell-extensions.gcampax.github.com"
      ];
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = true;
      clock-show-weekday = true;
      #gtk-theme = "Adwaita-dark";
    };
    # "org/gnome/desktop/session" = {                 # Doesn't seem to work
    #   idle-delay = "uint32 900";
    # };
    "org/gnome/desktop/privacy" = {
      report-technical-problems = "false";
    };
    "org/gnome/desktop/calendar" = {
      show-weekdate = true;
    };

    # Mutter window manager keybindings
    "org/gnome/desktop/wm/preferences" = {
      action-right-click-titlebar = "toggle-maximize";
      action-middle-click-titlebar = "minimize";
      resize-with-right-button = true;
      mouse-button-modifier = "<Super>";
      button-layout = ":minimize,close";
    };
    "org/gnome/desktop/wm/keybindings" = {
      maximize = ["<Ctrl><Super>Up"]; # For floating
      unmaximize = ["<Ctrl><Super>Down"];
      # maximize = ["@as []"];                          # For tilers
      # unmaximize = ["@as []"];
      switch-to-workspace-left = ["<Alt>Left"];
      switch-to-workspace-right = ["<Alt>Right"];
      switch-to-workspace-1 = ["<Alt>1"];
      switch-to-workspace-2 = ["<Alt>2"];
      switch-to-workspace-3 = ["<Alt>3"];
      switch-to-workspace-4 = ["<Alt>4"];
      switch-to-workspace-5 = ["<Alt>5"];
      switch-to-workspace-6 = ["<Alt>6"];
      switch-to-workspace-7 = ["<Alt>7"];
      switch-to-workspace-8 = ["<Alt>8"];
      switch-to-workspace-9 = ["<Alt>9"];
      move-to-workspace-left = ["<Shift><Alt>Left"];
      move-to-workspace-right = ["<Shift><Alt>Right"];
      move-to-workspace-1 = ["<Shift><Alt>1"];
      move-to-workspace-2 = ["<Shift><Alt>2"];
      move-to-workspace-3 = ["<Shift><Alt>3"];
      move-to-workspace-4 = ["<Shift><Alt>4"];
      move-to-workspace-5 = ["<Shift><Alt>5"];
      move-to-workspace-6 = ["<Shift><Alt>6"];
      move-to-workspace-7 = ["<Shift><Alt>7"];
      move-to-workspace-8 = ["<Shift><Alt>8"];
      move-to-workspace-9 = ["<Shift><Alt>9"];
      move-to-monitor-left = ["<Super><Alt>Left"];
      move-to-monitor-right = ["<Super><Alt>Right"];
      close = ["<Super>q" "<Alt>F4"];
      toggle-fullscreen = ["<Super>f"];
    };

    "org/gnome/mutter" = {
      workspaces-only-on-primary = false;
      center-new-windows = true;
      edge-tiling = false; # Disabled when tiling
    };
    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = ["<Ctrl><Super>Left"]; # For floating
      toggle-tiled-right = ["<Ctrl><Super>Right"];
      #toggle-tiled-left = ["@as []"];                 # For tilers
      #toggle-tiled-right = ["@as []"];
    };

    "org/gnome/settings-daemon/plugins/power" = {
      sleep-interactive-ac-type = "nothing";
    };

    # Custom keybindings gnome default
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>Return";
      command = "alacritty";
      name = "open-terminal";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<Super>e";
      command = "nautilus";
      name = "open-file-browser";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      binding = "<Super><Ctrl>w";
      command = "whatsapp-for-linux";
      name = "open-whatsapp";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
      binding = "<Super><Ctrl>t";
      command = "telegram-desktop";
      name = "open-telegram";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
      binding = "<Super><Ctrl>d";
      command = "Discord";
      name = "open-discord";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5" = {
      binding = "<Super><Ctrl>f";
      command = "firefox";
      name = "open-firefox";
    };

    # Dash-to-panel for status bar config
    #"org/gnome/shell/extension/dash-to-panel" = {     # Possibly need to set this manually
    #  animate-appicon-hover = true;
    #  animate-appicon-hover-animation-extent = "{'RIPPLE': 4, 'PLANK': 4, 'SIMPLE': 1}";
    #  appicon-margin = 0;
    #  appicon-padding = 3;
    #  available-monitors = [0];
    #  dot-position = "BOTTOM";
    #  dot-style-focused = "DASHES";
    #  dot-style-unfocused = "DOTS";
    #  group-apps = true;
    #  hot-keys = false;
    #  hotkeys-overlay-combo = "TEMPORARILY";
    #  intellihide = true;
    #  intellihide-behaviour = "ALL_WINDOWS";
    #  intellihide-hide-from-windows = true;
    #  intellihide-use-pressure = true;
    #  isolate-workspaces = false;
    #  leftbox-padding = -1;
    #  leftbox-size = 0;
    #  panel-anchors = ''{"0":"MIDDLE"}'';
    #  panel-element-positions = ''{"0":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"centerMonitor"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}]}'';
    #  panel-lengths = ''{"0":100}'';
    #  panel-positions = ''{"0":"TOP"}'';
    #  panel-sizes = ''{"0":32}'';
    #  primary-monitor = 0;
    #  show-appmenu = false;
    #  show-favorites = false;
    #  show-running-apps = false;
    #  status-icon-padding = -1;
    #  stockgs-force-hotcorner = false;
    #  stockgs-keep-dash = true;
    #  stockgs-keep-top-panel = false;
    #  taskbar-locked = false;
    #  trans-bg-color = "#3c3836";
    #  trans-dynamic-anim-target = 0.8;
    #  trans-dynamic-anim-time = 300;
    #  trans-dynamic-behavior = "ALL_WINDOWS";
    #  trans-dynamic-distance = 20;
    #  trans-gradient-bottom-color = "#3c3836";
    #  trans-gradient-bottom-opacity = 0.4;
    #  trans-gradient-top-color = "#3d3d3c";
    #  trans-gradient-top-opacity = 0.25;
    #  trans-panel-opacity = 0.5;
    #  trans-use-custom-bg = false;
    #  trans-use-custom-opacity = true;
    #  trans-use-dynamic-opacity = true;
    #  tray-padding = -1;
    #  tray-size = 0;
    #  window-preview-title-position = "TOP";
    #};
    "org/gnome/shell/extensions/caffeine" = {
      enable-fullscreen = true;
      restore-state = true;
      show-indicator = true;
      show-notification = false;
    };
    "org/gnome/shell/extensions/blur-my-shell" = {
      brightness = 0.8;
    };
    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      customize = true;
      sigma = 30;
    };
    "org/gnome/shell/extensions/blur-my-shell/overview" = {
      # Temporary = D2D Bug
      customize = true;
      sigma = 30;
    };
    # "org/gnome/shell/extensions/bluetooth-quick-connect" = {
    #   show-battery-icon-on = true;
    #   show-battery-value-on = true;
    # };

    # Forge Tiling window manager config
    "org/gnome/shell/extensions/forge" = {
      window-gap-size = 8;
      dnd-center-layout = "stacked";
    };
    "org/gnome/shell/extensions/forge/keybindings" = {
      # Set active colors manually
      focus-border-toggle = true;
      float-always-on-top-enabled = true;
      window-focus-up = ["<Super>Up"];
      window-focus-down = ["<Super>Down"];
      window-focus-left = ["<Super>Left"];
      window-focus-right = ["<Super>Right"];
      # window-swap-up = ["<Shift><Super>Up"];
      # window-swap-down = ["<Shift><Super>Down"];
      # window-swap-left = ["<Shift><Super>Left"];
      # window-swap-right = ["<Shift><Super>Right"];
      window-move-up = ["<Shift><Super>Up"];
      window-move-down = ["<Shift><Super>Down"];
      window-move-left = ["<Shift><Super>Left"];
      window-move-right = ["<Shift><Super>Right"];
      window-swap-last-active = ["@as []"];
      window-toggle-float = ["<Shift><Super>f"];
    };

    # Dash-to-Dock config
    # "org/gnome/shell/extensions/dash-to-dock" = {   # If dock if preferred
    #   multi-monitor = true;
    #   intelligent-autohide = true;
    #   dash-max-icon-size = 48;
    #   custom-theme-shrink = true;
    #   custom-theme-shrink-height = 1;
    #   background-color = ''rgb(47,45,45)'';
    #   transparency-mode = "FIXED";
    #   background-opacity = 0.8;
    #   show-apps-at-top = true;
    #   show-trash = true;
    #   hot-keys = false;
    #   click-action = "minimize-or-overview";
    #   scroll-action = "cycle-windows";
    #   isolate-monitors = true;

    # };
    # Vitals config for system monitor
    "org/gnome/shell/extensions/vitals" = {
      hot-sensors = ["_processor_usage_" "_memory_usage_" "_processor_frequency_" "__temperature_avg__"];
    };

    # Space-Bar config for showing which workspace in
    "org/gnome/shell/extensions/space-bar/appearance" = {
      active-workspace-background-color = "rgb(104,128,118)";
      active-workspace-border-color = "rgb(255,255,255)";
      active-workspace-text-color = "rgb(47,45,45)";
    };
    "org/gnome/shell/extensions/space-bar/behavior" = {
      indicator-style = "workspaces-bar";
      position = "left";
      position-index = 0;
      smart-workspace-names = false;
    };
    "org/gnome/shell/extensions/space-bar/shortcuts" = {
      open-menu = ["<Shift><Control><Alt>w"];
    };
    "org/gnome/shell/extensions/auto-move-windows" = {
      application-list = ["firefox.desktop:1" "Alacritty.desktop:2" "discord.desktop:3" "com.github.eneshecan.WhatsAppForLinux.desktop:3" "org.telegram.desktop.desktop:3" "spotify.desktop:4"];
    };
  };

  home.file = {
    ".config/gtk-4.0" = {
      source = ../../themes/gtk/${theme};
      recursive = true;
    };
    ".config/gtk-3.0" = {
      source = ../../themes/gtk/${theme};
      recursive = true;
    };
  };

  home.packages = with pkgs; [
    # gnomeExtensions.tray-icons-reloaded
    gnomeExtensions.forge
    #gnomeExtensions.space-bar
    #gnomeExtensions.removable-drive-menu
    gnomeExtensions.blur-my-shell
    #gnomeExtensions.burn-my-windows
    gnomeExtensions.caffeine
    #gnomeExtensions.custom-hot-corners-extended
    gnomeExtensions.clipboard-indicator
    #gnomeExtensions.coverflow-alt-tab
    #gnomeExtensions.dash-to-dock
    #gnomeExtensions.dash-to-panel
    gnomeExtensions.user-avatar-in-quick-settings
    gnomeExtensions.gnome-40-ui-improvements
    gnomeExtensions.gsconnect
    gnomeExtensions.impatience
    #gnomeExtensions.quick-settings-tweaker
    gnomeExtensions.vitals
    gnomeExtensions.rounded-window-corners
    #gnomeExtensions.just-perfection
    #gnomeExtensions.advanced-alttab-window-switcher
  ];
}
