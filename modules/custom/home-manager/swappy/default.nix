{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.swappy;
in {
  options.hm.swappy = {
    enable = mkEnableOption "Swappy screenshot annotation tool";

    save_dir = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/Pictures/Screenshots";
      description = "Default directory to save annotated images.";
    };

    save_filename_format = mkOption {
      type = types.str;
      default = "swappy-%Y%m%d-%H%M%S.png";
      description = "The format string for saved filenames.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.swappy];

    # Ensure the screenshot directory exists
    home.activation.createSwappyDir = hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p ${cfg.save_dir}
    '';

    # Manage the config file
    # We use xdg.configFile for cleaner integration
    xdg.configFile."swappy/config".text = ''
      [Default]
      save_dir=${cfg.save_dir}
      save_filename_format=${cfg.save_filename_format}
      show_panel=false
      line_size=5
      text_size=20
      text_font=sans-serif
      paint_mode=brush
      early_exit=true
      fill_shape=false
    '';
  };
}
