{pkgs, ...}: {
  home.packages = with pkgs.xfce; [
    # For file manager
    thunar
    tumbler
    exo
    thunar-archive-plugin
    thunar-volman
  ];

  home.file = {
    ".config/Thunar" = {
      source = ./uca.xml;
      recursive = true;
    };
  };
}
