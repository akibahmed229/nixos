{
  pkgs,
  self,
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkImport mkRelativeToRoot;
in {
  nixpkgs = {
    # You can add overlays here
    overlays = [
      self.overlays.discord-overlay
      self.overlays.nvim-overlay
    ];
  };

  # imports from the predefiend modules folder
  imports = mkImport {
    path = mkRelativeToRoot "modules/predefiend/home-manager";
    ListOfPrograms = ["firefox" "spotify" "discord" "zsh" "tmux" "lf" "ags" "git" "sops" "thunar" "swaylock" "wofi" "wlogout" "swappy"];
  };

  home.packages = with pkgs; [
    self.packages.${pkgs.system}.wallpaper
    neovim
  ];
}
