# DWM home-manager configuration
{
  self,
  pkgs,
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkImport mkRelativeToRoot;
in {
  imports = mkImport {
    path = mkRelativeToRoot "modules/predefiend/home-manager";
    ListOfPrograms = ["firefox" "zsh" "tmux" "lf" "git"];
  };

  home.packages = with pkgs; [
    self.packages.${pkgs.system}.wallpaper
    picom
    (st.overrideAttrs {
      src = ./st;
    })
    (slstatus.overrideAttrs {
      src = ./slstatus;
    })
    (dmenu.overrideAttrs {
      src = ./dmenu;
    })
  ];
}
