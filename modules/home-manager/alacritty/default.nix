{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.alacritty;
in {
  options.hm.alacritty = {
    enable = mkEnableOption "Alacritty terminal configuration";

    fontSize = mkOption {
      type = types.number;
      default = 11;
      description = "Font size for the terminal.";
    };

    opacity = mkOption {
      type = types.number;
      default = 0.9;
      description = "Background opacity from 0 to 1.";
    };

    font = mkOption {
      type = types.str;
      default = "JetBrainsMono Nerd Font";
      description = "Font family to use.";
    };

    extraSettings = mkOption {
      type = types.attrs;
      default = {};
      description = "Additional Alacritty settings to merge.";
    };
  };

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      package = pkgs.alacritty;

      settings =
        recursiveUpdate {
          window = {
            padding = {
              x = 16;
              y = 16;
            };
            dynamic_title = true;
          };

          cursor = {
            style = {
              shape = "Beam";
              blinking = "On";
            };
          };

          # Merge in your existing TOML-based config if you still want it
          # Or just move your colors and keybinds into extraSettings
        }
        cfg.extraSettings;
    };
  };
}
