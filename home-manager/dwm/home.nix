{
  self,
  pkgs,
  ...
}: {
  imports = self.lib.mkImport {
    path = self.lib.mkRelativeToRoot "modules/predefiend/home-manager";
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
