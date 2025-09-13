{pkgs, ...}: {
  home.packages = with pkgs; [direnv];

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    package = pkgs.direnv;
  };
}
