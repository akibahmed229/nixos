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
        en = true;
        user = user;
      };
      nvim.en = true;
      thunar.en = true;
      quickshell.en = true;
      kitty.en = true;
      swappy.en = true;
      wofi.en = true;
      spotify.en = true;
    }
  ];

  home.packages = with pkgs; [
    # 1. Screenshot & Screen Tools
    self.packages.${pkgs.stdenv.hostPlatform.system}.screenshot # Screenshot tool.
    imagemagick # Image manipulation tool, often used for screenshots.

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
