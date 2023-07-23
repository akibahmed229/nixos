#
# Gnome Home-Manager Configuration
#
# Dconf settings can be found by running "$ dconf watch /"
#

{ config, lib, pkgs, ... }:

{
  dconf.settings = {
    "org/gnome/shell" = {
      favorite-apps = [
        "brave-browser.desktop"
        "Alacritty.desktop"
        "code.desktop"
        "android-studio.desktop"
        "com.discordapp.Discord.desktop"
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
        "apps-menu@gnome-shell-extensions.gcampax.github.com"
        "drive-menu@gnome-shell-extensions.gcampax.github.com"
        "dash-to-panel@jderose9.github.com"
        "caffeine@patapon.info"
        "clipboard-indicator@tudmotu.com"
        # "bluetooth-quick-connect@bjarosze.gmail.com"
        "gsconnect@andyholmes.github.io"
        "forge@jmmaranan.com"
        "dash-to-dock@micxgx.gmail.com"             # Dash to panel alternative
        "Vitals@CoreCoding.com"
        "quick-settings-avatar@d-go"
        "quick-settings-tweaks@qwreey"
        "gnome-ui-tune@itstime.tech"
        "custom-hot-corners-extended@G-dH.github.com"
        "impatience@gfxmonk.net"
        "burn-my-windows@schneegans.github.com"
      ];
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
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
    "org/gnome/desktop/wm/preferences" = {
      action-right-click-titlebar = "toggle-maximize";
      action-middle-click-titlebar = "minimize";
      resize-with-right-button = true;
      mouse-button-modifier = "<Super>";
      button-layout = ":minimize,close";
    };
    "org/gnome/desktop/wm/keybindings" = {
      # maximize = ["<Super>Up"];                     # For floating
      # unmaximize = ["<Super>Down"];
      maximize = ["@as []"];                          # For tilers
      unmaximize = ["@as []"];
      switch-to-workspace-left = ["<Alt>Left"];
      switch-to-workspace-right = ["<Alt>Right"];
      switch-to-workspace-1 = ["<Alt>1"];
      switch-to-workspace-2 = ["<Alt>2"];
      switch-to-workspace-3 = ["<Alt>3"];
      switch-to-workspace-4 = ["<Alt>4"];
      switch-to-workspace-5 = ["<Alt>5"];
      move-to-workspace-left = ["<Shift><Alt>Left"];
      move-to-workspace-right = ["<Shift><Alt>Right"];
      move-to-workspace-1 = ["<Shift><Alt>1"];
      move-to-workspace-2 = ["<Shift><Alt>2"];
      move-to-workspace-3 = ["<Shift><Alt>3"];
      move-to-workspace-4 = ["<Shift><Alt>4"];
      move-to-workspace-5 = ["<Shift><Alt>5"];
      move-to-monitor-left = ["<Super><Alt>Left"];
      move-to-monitor-right = ["<Super><Alt>Right"];
      close = ["<Super>q" "<Alt>F4"];
      toggle-fullscreen = ["<Super>f"];
    };

    "org/gnome/mutter" = {
      workspaces-only-on-primary = false;
      center-new-windows = true;
      edge-tiling = false;                            # Disabled when tiling
    };
    "org/gnome/mutter/keybindings" = {
      #toggle-tiled-left = ["<Super>Left"];           # For floating
      #toggle-tiled-right = ["<Super>Right"];
      toggle-tiled-left = ["@as []"];                 # For tilers
      toggle-tiled-right = ["@as []"];
    };

    "org/gnome/settings-daemon/plugins/power" = {
      sleep-interactive-ac-type = "nothing";
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>Return";
      command = "alacritty";
      name = "open-terminal";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      binding = "<Super>e";
      command = "nautilus";
      name = "open-file-browser";
    };

    "org/gnome/shell/extension/dash-to-panel" = {     # Possibly need to set this manually
    animate-appicon-hover = true;
    animate-appicon-hover-animation-extent = "{'RIPPLE': 4, 'PLANK': 4, 'SIMPLE': 1}";
    appicon-margin = 1;
    appicon-padding = 2;
    available-monitors = [0];
    dot-position = "BOTTOM";
    dot-style-focused = "SOLID";
    dot-style-unfocused = "DASHES";
    group-apps = true;
    hot-keys = false;
    hotkeys-overlay-combo = "TEMPORARILY";
    intellihide = true;
    intellihide-hide-from-windows = true;
    intellihide-use-pressure = true;
    isolate-workspaces = false;
    leftbox-padding = -1;
    leftbox-size = 0;
    panel-anchors = ''{"0":"MIDDLE"}'';
    panel-element-positions = ''{"0":[{"element":"showAppsButton","visible":false,"position":"centerMonitor"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedBR"},{"element":"leftBox","visible":true,"position":"centerMonitor"},{"element":"dateMenu","visible":true,"position":"centerMonitor"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}]}'';
    panel-lengths = ''{"0":99}'';
    panel-positions = ''{"0":"TOP"}'';
    panel-sizes = ''{"0":32}'';
    primary-monitor = 0;
    show-appmenu = false;
    show-favorites = false;
    status-icon-padding = -1;
    stockgs-force-hotcorner = false;
    stockgs-keep-dash = true;
    stockgs-keep-top-panel = false;
    trans-panel-opacity = 0.0;
    trans-use-custom-bg = false;
    trans-use-custom-opacity = true;
    trans-use-dynamic-opacity = false;
    tray-padding = -1;
    tray-size = 0; 
    window-preview-title-position = "TOP";
    };
    "org/gnome/shell/extensions/caffeine" = {
      enable-fullscreen = true;
      restore-state = true;
      show-indicator = true;
      show-notification = false;
    };
    "org/gnome/shell/extensions/blur-my-shell" = {
      brightness = 0.9;
    };
    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      customize = true;
      sigma = 30;
    };
    "org/gnome/shell/extensions/blur-my-shell/overview" = { # Temporary = D2D Bug
      customize = true;
      sigma = 30;
    };
   # "org/gnome/shell/extensions/bluetooth-quick-connect" = {
   #   show-battery-icon-on = true;
   #   show-battery-value-on = true;
   # };
    "org/gnome/shell/extensions/forge" = {
      window-gap-size = 8;
      dnd-center-layout = "stacked";
    };
    "org/gnome/shell/extensions/forge/keybindings" = {      # Set active colors manually
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
    "org/gnome/shell/extensions/dash-to-dock" = {   # If dock if preferred
       multi-monitor = true;
       intelligent-autohide = true;
       dash-max-icon-size = 48;
       custom-theme-shrink = true;
       custom-theme-shrink-height = 1;
       transparency-mode = "FIXED";
       background-opacity = 20.0;
       show-apps-at-top = true;
       show-trash = true;
       hot-keys = false;
       click-action = "minimize-or-overview";
       scroll-action = "cycle-windows";
       isolate-monitors = true;

     };
  };

  home.packages = with pkgs; [
    # gnomeExtensions.tray-icons-reloaded
    gnomeExtensions.forge
    gnomeExtensions.removable-drive-menu
    gnomeExtensions.clipboard-indicator
    # gnomeExtensions.bluetooth-quick-connect
    gnomeExtensions.blur-my-shell
    gnomeExtensions.burn-my-windows
    gnomeExtensions.caffeine
    gnomeExtensions.custom-hot-corners-extended
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.coverflow-alt-tab
    gnomeExtensions.dash-to-dock
    gnomeExtensions.dash-to-panel
    gnomeExtensions.user-avatar-in-quick-settings
    gnomeExtensions.gnome-40-ui-improvements
    gnomeExtensions.gsconnect
    #gnomeExtensions.impatience
    gnomeExtensions.quick-settings-tweaker
    gnomeExtensions.tiling-assistant
    gnomeExtensions.vitals
    gnomeExtensions.pop-shell
  ];
}
