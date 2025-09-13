{pkgs, ...}: {
  home.packages = with pkgs; [atuin];

  programs.atuin = {
    enable = true;
    daemon.enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    package = pkgs.atuin;
  };
}
