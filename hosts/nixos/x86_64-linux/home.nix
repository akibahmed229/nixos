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

  nixpkgs = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = ["pnpm-10.29.2" "electron-40.10.5"];
    };
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      self.overlays.default
      inputs.nur.overlays.default # accisable through: `pkgs.nur.repos.<name>.<packages>`
    ];
  };

  hm = {
    flake-sync.en = true;
    xdg.en = true;
    zsh.en = true;
    starship.en = true;
    yazi.en = true;
    atuin.en = true;
    direnv.en = true;
    fastfetch.en = true;
    libinput.en = true;
    pipewire.en = true;
    wireplumber.en = true;

    tmux = {
      en = true;
      systemden = true;
    };

    stylix = {
      en = true;
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
    awww # Sway wallpaper manager.

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
