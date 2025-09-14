# virt home-manager configuration
{
  pkgs,
  self,
  lib,
  user,
  inputs,
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkImport mkRelativeToRoot;
in {
  imports =
    [
      self.homeModules.default # Custom home-manager modules
      inputs.nix-index-database.homeModules.nix-index
    ]
    ++ mkImport {
      path = mkRelativeToRoot "modules/predefiend/home-manager";
      ListOfPrograms =
        [
          "firefox"
          "zsh"
          "tmux"
          "lf"
          "atuin"
          "nixvim"
          "stylix"
          "thunar"
          "fastfetch"
          "xdg"
        ]
        ++ lib.optionals (user == "akib") [
          "git"
          "sops"
          "ssh"
          "libinput"
          "wireplumber"
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
    xdg-utils # Utilities for managing desktop integration.
    tree # Command-line directory tree viewer.
    ripgrep # Line-oriented search tool.
    bibata-cursors # Cursor theme.
    adw-gtk3 # Adwaita theme for GTK 3.
    brightnessctl # Brightness control tool.

    # 2. Multimedia & Audio
    playerctl # Music player controller.
    ddcutil # Desktop Monitor settings controller

    # 3. Screenshot & Screen Tools
    self.packages.${pkgs.system}.wallpaper
    self.packages.${pkgs.system}.screenshot # Screenshot tool.
    imagemagick # Image manipulation tool, often used for screenshots.
    self.packages.${pkgs.system}.custom_nsxiv # Image viewer.
    xclip
    klipper

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
