{
  pkgs,
  self,
  inputs,
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkRelativeToRoot;
in {
  # imports from the predefiend modules folder
  imports = [
    self.homeModules.default # Custom home-manager modules
    inputs.nix-index-database.homeModules.nix-index
  ];

  hm = {
    flake-sync.enable = true;
    xdg.enable = true;
    zsh.enable = true;
    starship.enable = true;
    yazi.enable = true;
    atuin.enable = true;
    direnv.enable = true;
    fastfetch.enable = true;
    libinput.enable = true;
    pipewire.enable = true;
    wireplumber.enable = true;

    tmux = {
      enable = true;
      systemdEnable = true;
    };

    stylix = {
      enable = true;
      themeScheme = mkRelativeToRoot "public/themes/base16Scheme/gruvbox-dark-soft.yaml";
    };
  };

  home.packages = with pkgs; [
    # 1. Desktop Environment & Customization
    self.packages.${pkgs.stdenv.hostPlatform.system}.wallpaper # Wallpaper management tool.
    nwg-look # Look and feel customization tool.
    xdg-utils # Utilities for managing desktop integration.
    tree # Command-line directory tree viewer.
    hwinfo # Hardware information tool.
    ripgrep # Line-oriented search tool.
    bibata-cursors # Cursor theme.
    adw-gtk3 # Adwaita theme for GTK 3.
    qt6Packages.qtstyleplugin-kvantum # Theme engine for Qt
    swww # Sway wallpaper manager.

    # 2. Multimedia & Audio
    playerctl # Music player controller.
    ddcutil # Desktop Monitor settings controller
    brightnessctl # Brightness control tool.
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
  # enable systemd service for per-user
  systemd.user.enable = true;
}
