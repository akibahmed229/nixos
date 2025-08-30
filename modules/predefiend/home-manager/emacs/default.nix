{pkgs, ...}: {
  services.emacs = {
    enable = true;
    package = pkgs.emacs-gtk;
  };

  home = {
    packages = with pkgs; [emacs-gtk];
    file = {
      ".config/emacs" = {
        source = ./config;
        recursive = true;
      };
    };
  };
}
