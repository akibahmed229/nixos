{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.atuin;
in {
  options.hm.atuin = {
    en = mkEnableOption "Atuin shell history sync configuration";

    sync = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to en Atuin's sync features.";
    };
  };

  config = mkIf cfg.en {
    programs.atuin = {
      enable = true;
      package = pkgs.atuin;

      # Integration
      enableZshIntegration = true;
      enableBashIntegration = true;

      # Background daemon for faster database access
      daemon.enable = true;

      settings = {
        # Visual style
        style = "compact";
        inline_height = 20;
        show_preview = true;

        # History behavior
        enter_accept = true;
        sync_address = "https://api.atuin.sh";
        auto_sync = cfg.sync;
        update_check = false;
      };
    };
  };
}
