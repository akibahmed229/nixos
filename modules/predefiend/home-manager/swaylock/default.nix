{pkgs, ...}: {
  home.packages = with pkgs; [
    swaylock-effects
    swaylock
  ];

  home.file = {
    ".config/swaylock" = {
      source = ./config;
      recursive = true;
    };
  };
}
