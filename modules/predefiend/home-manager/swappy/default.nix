{pkgs, ...}: {
  home.packages = with pkgs; [
    swappy
  ];

  home.file = {
    ".config/swappy" = {
      source = ./config;
      recursive = true;
    };
  };
}
