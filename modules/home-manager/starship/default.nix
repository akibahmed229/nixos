{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.starship;
in {
  options.hm.starship = {
    en = mkEnableOption "Starship prompt configuration";

    configPath = mkOption {
      type = types.path;
      default = ./config/starship.toml;
      description = "Path to the starship.toml configuration file.";
    };
  };

  config = mkIf cfg.en {
    programs.starship = {
      enable = true;
      package = pkgs.starship;

      # Integration settings
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;

      # Reading the TOML file
      settings = fromTOML (builtins.readFile cfg.configPath);
    };
  };
}
