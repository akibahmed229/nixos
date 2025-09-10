{
  pkgs,
  self,
  lib,
  user,
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkImport mkRelativeToRoot;
in {
  nixpkgs = {
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };

    # You can add overlays here
    overlays = [
      self.overlays.discord-overlay
    ];
  };

  # imports from the predefiend modules folder
  imports = mkImport {
    path = mkRelativeToRoot "modules/predefiend/home-manager";
    ListOfPrograms =
      [
        "firefox"
        "spotify"
        "stylix"
        "nixvim"
        "discord"
        "zsh"
        "tmux"
        "yazi"
        "quickshell"
        "thunar"
        "wofi"
        "swappy"
        "atuin"
        "emacs"
      ]
      ++ lib.optionals (user == "akib") [
        "git"
        "sops"
      ];
  };

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
}
