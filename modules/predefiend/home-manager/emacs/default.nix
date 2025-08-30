{pkgs, ...}: {
  services.emacs = {
    enable = true;
    package = pkgs.emacs-gtk;
  };

  home.file = {
    ".config/emacs" = {
      source = ./config;
      recursive = true;
    };
  };
}
