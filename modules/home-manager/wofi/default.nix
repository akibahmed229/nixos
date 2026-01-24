{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.wofi;
in {
  options.hm.wofi = {
    enable = mkEnableOption "Wofi custom configuration";

    terminal = mkOption {
      type = types.str;
      default = "kitty";
      description = "Terminal emulator to use for wofi commands.";
    };

    extraSettings = mkOption {
      type = types.attrs;
      default = {};
      description = "Extra configuration options for Wofi settings.";
    };
  };

  config = mkIf cfg.enable {
    programs.wofi = {
      enable = true;
      package = pkgs.wofi;

      settings =
        recursiveUpdate {
          allow_images = true;
          show = "drun";
          prompt = "Search";
          term = cfg.terminal;
          print_command = true;
          insensitive = true;
          columns = 1;
          no_actions = true;
          hide_scroll = true;
          # Automatically point to the style file managed by this module
          style = "${config.xdg.configHome}/wofi/style.css";
        }
        cfg.extraSettings;
    };
  };
}
