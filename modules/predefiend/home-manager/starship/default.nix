{pkgs, ...}: {
  programs.starship = {
    enable = true;
    package = pkgs.starship;
    enableZshIntegration = true;
    enableBashIntegration = true;
    settings =
      builtins.fromTOML
      (builtins.readFile ./config/starship.toml);
  };
}
