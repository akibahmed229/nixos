{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.kitty;
in {
  options.hm.kitty = {
    enable = mkEnableOption "Kitty terminal configuration";

    # Option to override or add specific settings via Nix
    extraSettings = mkOption {
      type = types.attrs;
      default = {};
      description = "Additional Kitty configuration settings as a Nix attribute set.";
    };
  };

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      package = pkgs.kitty;

      shellIntegration = {
        enableBashIntegration = true;
        enableZshIntegration = true;
      };

      # 1. Read your existing physical kitty.conf file
      # 2. Add extra settings defined in your home.nix
      # 3. Use 'settings' instead of 'extraConfig' for better Nix integration
      settings =
        recursiveUpdate
        # This converts your config file into an attribute set
        # Note: If your kitty.conf is very complex/non-standard,
        # use extraConfig = builtins.readFile ./kitty.conf instead.
        {}
        cfg.extraSettings;

      # Improvement: We use extraConfig to append the raw file content
      # This ensures all your existing keybinds and aliases are preserved.
      extraConfig = builtins.readFile ./kitty.conf;
    };
  };
}
