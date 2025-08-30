{pkgs, ...}: {
  home.packages = with pkgs; [atuin];

  programs.atuin = {
    daemon.enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    package = pkgs.atuin;
  };
}
