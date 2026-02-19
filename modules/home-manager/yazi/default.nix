{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.yazi;
in {
  options.hm.yazi = {
    enable = mkEnableOption "Yazi terminal file manager configuration";

    showHidden = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to show hidden files by default.";
    };
  };

  config = mkIf cfg.enable {
    # We use programs.yazi.package instead of home.packages to let HM manage it
    programs.yazi = {
      enable = true;
      enableZshIntegration = true; # Makes 'y' or 'yy' available in zsh
      enableBashIntegration = true;
      shellWrapperName = "y";

      settings = {
        manager = {
          layout = [1 4 3]; # Ratio of Parent : Current : Preview panes
          sort_by = "natural";
          sort_sensitive = true;
          sort_reverse = false;
          sort_dir_first = true;
          linemode = "none";
          show_hidden = cfg.showHidden;
          show_symlink = true;
        };

        preview = {
          image_filter = "lanczos3";
          image_quality = 90;
          tab_size = 1;
          max_width = 600;
          max_height = 900;
          cache_dir = "";
          ueberzug_scale = 1;
          ueberzug_offset = [0 0 0 0];
        };

        tasks = {
          micro_workers = 5;
          macro_workers = 10;
          bizarre_retry = 5;
        };
      };
    };
  };
}
