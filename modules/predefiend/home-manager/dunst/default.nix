{pkgs, ...}: {
  home.packages = with pkgs; [
    dunst
  ];
  home.file = {
    ".config/dunst" = {
      source = ./others/dunst;
      recursive = true;
    };
  };
}
