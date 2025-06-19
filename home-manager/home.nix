# common home-manager configuration across all machines
{
  pkgs,
  user,
  inputs,
  lib,
  self,
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkRelativeToRoot;

  HomeModuleFolder = mkRelativeToRoot "modules/predefiend/home-manager";
in {
  imports = [
    inputs.nix-index-database.hmModules.nix-index
    {programs.nix-index-database.comma.enable = true;} # optional to also wrap and install comma
    self.homeModules.default # Custom home-manager modules
  ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home = {
    packages = with pkgs; [
      # 1. System Utilities
      xdg-utils # Utilities for managing desktop integration.
      tree # Command-line directory tree viewer.
      hwinfo # Hardware information tool.
      ripgrep # Line-oriented search tool.

      # 2. Desktop Environment & Customization
      bibata-cursors # Cursor theme.
      adw-gtk3 # Adwaita theme for GTK 3.

      # 3. Terminal Emulators
      alacritty # GPU-accelerated terminal emulator.
      kitty # GPU-based terminal emulator.

      # # Adds the 'hello' command to your environment. It prints a friendly
      # # "Hello, world!" when run.
      # pkgs.hello

      # # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?
      # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

      # # You can also create simple shell scripts directly inside your
      # # configuration. For example, this adds a command 'my-hello' to your
      # # environment:
      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
    ];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    file = {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;

      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';

      ".config/alacritty" = {
        source = HomeModuleFolder + "/alacritty";
        recursive = true;
      };

      ".config/fastfetch" = {
        source = HomeModuleFolder + "/fastfetch";
        recursive = true;
      };
      ".config/OpenRGB" = lib.mkIf (user == "akib") {
        source = HomeModuleFolder + "/openrgb";
        recursive = true;
      };

      # The camera's /dev/video file is kept open (without streaming), sadly causing the camera to be powered on what looks to be most devices.
      # For some reason, this completely nullifies the soc power management on modern laptops and can result in increases from 3W to 8W at idle!
      ".config/wireplumber" = {
        source = HomeModuleFolder + "/wireplumber"; # tells wireplumber to ignore cameras
        recursive = true;
      };
      # libinput config that will disable mouse acceleration
      ".config/libinput" = {
        source = HomeModuleFolder + "/libinput";
        recursive = true;
      };
      ".ssh" = lib.mkIf (user == "akib") {
        source = HomeModuleFolder + "/ssh";
        recursive = true;
      };
    };

    # You can also manage environment variables but you will have to manually
    # source
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/akib/etc/profile.d/hm-session-vars.sh
    #
    # if you don't want to manage your shell through Home Manager.
    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  # GTK and QT themes ( custom home-manager module )
  theme.qt.enable = false;

  programs.kitty = {
    enable = true;
    package = pkgs.kitty;
    shellIntegration.enableBashIntegration = true;
    shellIntegration.enableZshIntegration = true;
    extraConfig = builtins.readFile (HomeModuleFolder + "/kitty/kitty.conf");
  };

  # Create XDG Dirs
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
    };
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "image/jpeg" = ["org.gnome.eog.desktop" "image-roll.desktop" "feh.desktop"];
        "image/png" = ["org.gnome.eog.desktop" "image-roll.desktop" "feh.desktop"];
        "text/plain" = "nvim.desktop";
        "text/csv" = "nvim.desktop";
        "application/pdf" = ["org.gnome.Evince.desktop" "firefox.desktop" "google-chrome.desktop"];
        "application/zip" = ["org.gnome.FileRoller.desktop" "org.kde.ark.desktop"];
        "application/x-tar" = "org.gnome.FileRoller.desktop";
        "application/x-bzip2" = "org.gnome.FileRoller.desktop";
        "application/x-gzip" = "org.gnome.FileRoller.desktop";
        "application/x-bittorrent" = "org.qbittorrent.qBittorrent.desktop";
        "x-scheme-handler/mailto" = ["gmail.desktop"];
        "x-scheme-handler/tg" = ["userapp-Telegram Desktop-0OI4J2.desktop" "userapp-Telegram Desktop-CUQDL2.desktop" "userapp-Telegram Desktop-7DXZL2.desktop" "userapp-Telegram Desktop-XB3XL2.desktop" "userapp-Telegram Desktop-KLEZM2.desktop" "org.telegram.desktop.desktop"];
        "audio/mp3" = "vlc.desktop";
        "audio/x-matroska" = "vlc.desktop";
        "video/webm" = "vlc.desktop";
        "video/mp4" = "vlc.desktop";
        "video/x-matroska" = "vlc.desktop";
        "inode/directory" = "pcmanfm.desktop";
      };
    };
    desktopEntries.image-roll = {
      name = "image-roll";
      exec = "${pkgs.image-roll}/bin/image-roll %F";
      mimeType = ["image/*"];
    };
    desktopEntries.gmail = {
      name = "Gmail";
      exec = ''xdg-open "https://mail.google.com/mail/?view=cm&fs=1&to=%u"'';
      mimeType = ["x-scheme-handler/mailto"];
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
