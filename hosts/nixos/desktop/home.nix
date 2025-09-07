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
    self.packages.${pkgs.system}.wallpaper
  ];
}
