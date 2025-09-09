{
  pkgs,
  lib,
  config,
  self,
  ...
}: let
  niriConfig = "$FLAKE_DIR/home-manager/niri/niri";
  niriTarget = "${config.home.homeDirectory}/.config/niri";
in {
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

  home.activation.symlinkNiriWMConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ln -sfn "${niriConfig}" "${niriTarget}"
  '';

  services = {
    # For auto mounting USB devices
    udiskie = {
      enable = true;
      automount = true;
      notify = true;
    };
  };
}
