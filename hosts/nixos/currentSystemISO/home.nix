{
  pkgs,
  self,
  inputs,
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkImport mkRelativeToRoot;
in {
  # imports from the predefiend modules folder
  imports =
    [
      self.homeModules.default # Custom home-manager modules
      inputs.nix-index-database.homeModules.nix-index
    ]
    ++ mkImport {
      path = mkRelativeToRoot "modules/predefiend/home-manager";
      ListOfPrograms = [
        "zsh"
        "tmux"
        "lf"
        "quickshell"
        "nixvim"
        "kitty"
        "fastfetch"
        "atuin"
        "wofi"
        "thunar"
        "swappy"
        "xdg"
        "stylix"
        "firefox"
        "spotify"
      ];
    };

  nixpkgs = {
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  home.packages = with pkgs; [
    # 1. Desktop Environment & Customization
    self.packages.${pkgs.system}.wallpaper # Wallpaper management tool.
    xdg-utils # Utilities for managing desktop integration.
    tree # Command-line directory tree viewer.
    ripgrep # Line-oriented search tool.
    bibata-cursors # Cursor theme.
    adw-gtk3 # Adwaita theme for GTK 3.
    swww # Sway wallpaper manager.

    # 2. Multimedia & Audio
    playerctl # Music player controller.
    ddcutil # Desktop Monitor settings controller
    brightnessctl # Brightness control tool.

    # 3. Screenshot & Screen Tools
    self.packages.${pkgs.system}.wallpaper
    self.packages.${pkgs.system}.screenshot # Screenshot tool.
    imagemagick # Image manipulation tool, often used for screenshots.
    self.packages.${pkgs.system}.custom_nsxiv # Image viewer.

    # 4. Clipboard Management
    cliphist # Clipboard history management tool.
    wl-clipboard # Wayland clipboard tool.

    # 5. Utility
    udiskie
  ];

  services = {
    # For auto mounting USB devices
    udiskie = {
      enable = true;
      automount = true;
      notify = true;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
  # enable systemd service for per-user
  systemd.user.enable = true;
}
