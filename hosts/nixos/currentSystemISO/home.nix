{
  pkgs,
  self,
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkImport mkRelativeToRoot;
in {
  # imports from the predefiend modules folder
  imports = mkImport {
    path = mkRelativeToRoot "modules/predefiend/home-manager";
    ListOfPrograms = ["zsh" "tmux" "lf" "ags"];
  };

  home.packages = with pkgs; [
    self.packages.${pkgs.system}.wallpaper
    xfce.exo
  ];
}
