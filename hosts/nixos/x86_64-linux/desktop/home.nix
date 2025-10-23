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
  # imports from the predefiend modules folder
  imports = mkImport {
    path = mkRelativeToRoot "modules/predefiend/home-manager";
    ListOfPrograms =
      [
        "firefox"
        "spotify"
        "nvim"
        "vencord"
        "quickshell"
        "wofi"
        "swappy"
        "emacs"
        "alacritty"
        "kitty"
        "thunar"
        "hypridle"
        "espanso"
      ]
      ++ lib.optionals (user == "akib") [
        "git"
        "sops"
        "ssh"
        "openrgb"
      ];
  };

  home.packages = with pkgs; [
    # 2. Screenshot & Screen Tools
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
