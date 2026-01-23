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
    ListOfPrograms = lib.optionals (user == "akib") [
      "git"
      "sops"
      "ssh"
      "openrgb"
    ];
  };

  home.packages = with pkgs; [
    # 2. Screenshot & Screen Tools
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

  hm = {
    firefox = {
      enable = true;
      user = user;
    };

    nvim.enable = true;
    quickshell.enable = true;
    spotify.enable = true;
    vencord.enable = true;
    wofi.enable = true;
    swappy.enable = true;
    alacritty.enable = true;
    kitty.enable = true;
    thunar.enable = true;
    espanso.enable = true;
    gemini-cli.enable = true;
    hypridle.enable = true;
    emacs.enable = true;
  };

  services = {
    # For auto mounting USB devices
    udiskie = {
      enable = true;
      automount = true;
      notify = true;
    };
  };
}
