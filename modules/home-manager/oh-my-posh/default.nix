{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.oh-my-posh;
in {
  options.hm.oh-my-posh = {
    enable = mkEnableOption "Oh My Posh prompt configuration";

    theme = mkOption {
      type = types.str;
      default = "gruvbox";
      description = "The theme to use for Oh My Posh.";
    };
  };

  config = mkIf cfg.enable {
    programs.oh-my-posh = {
      enable = true;
      package = pkgs.oh-my-posh;

      # Shell Integrations
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;

      # Theme Selection
      useTheme = cfg.theme;
    };
  };
}
