{pkgs, ...}: {
  programs.wlogout = {
    enable = true;
    package = pkgs.wlogout;
  };
  home.file = {
    ".config/wlogout" = {
      source = ./config;
      recursive = true;
    };
  };
}
