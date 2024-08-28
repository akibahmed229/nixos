{pkgs, ...}: {
  programs.wofi = {
    enable = true;
    package = pkgs.wofi;
    settings = {
      mode = "drun";
      allow_images = true;
    };
  };
}
