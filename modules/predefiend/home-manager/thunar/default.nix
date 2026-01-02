{ pkgs, ... }:
{
  home.packages = (
    with pkgs;
    [
      kdePackages.ark
      xfce4-exo
      thunar
      tumbler
      thunar-archive-plugin
      thunar-volman
    ]
  );

  home.file = {
    ".config/Thunar" = {
      source = ./config;
      recursive = true;
    };
  };
}
