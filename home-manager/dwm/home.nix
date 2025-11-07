# DWM home-manager configuration
{
  self,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    cliphist
    wl-clipboard
    self.packages.${pkgs.stdenv.hostPlatform.system}.wallpaper
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
