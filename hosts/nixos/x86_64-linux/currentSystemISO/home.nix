{
  pkgs,
  self,
  lib,
  user,
  ...
}: {
  hm = lib.mkMerge [
    {
      firefox = {
        enable = true;
        user = user;
      };
      nvim.enable = true;
      thunar.enable = true;
      quickshell.enable = true;
      kitty.enable = true;
      swappy.enable = true;
      wofi.enable = true;
      spotify.enable = true;
    }
  ];

  home.packages = with pkgs; [
    # 1. Screenshot & Screen Tools
    self.packages.${pkgs.stdenv.hostPlatform.system}.wallpaper
    self.packages.${pkgs.stdenv.hostPlatform.system}.screenshot # Screenshot tool.
    imagemagick # Image manipulation tool, often used for screenshots.
    self.packages.${pkgs.stdenv.hostPlatform.system}.custom_nsxiv # Image viewer.

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
