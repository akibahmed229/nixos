{pkgs, ...}: {
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    settings = builtins.readFile ./config;
    style = builtins.readFile ./style.css;
  };
}
