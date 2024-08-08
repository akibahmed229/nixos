# Home Manager configuration
{pkgs, ...}: {
  imports = [];

  home = {
    packages = with pkgs; [
      # Core
      zsh
    ];
  };

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
    mime.enable = true;
    mimeApps.enable = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  news.display = "silent";
  programs.home-manager.enable = true;
}
