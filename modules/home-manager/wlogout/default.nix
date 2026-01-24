{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.wlogout;
in {
  options.hm.wlogout = {
    enable = mkEnableOption "wlogout logout menu configuration";

    layoutPath = mkOption {
      type = types.path;
      default = ./config/layout;
      description = "Path to the wlogout layout JSON file.";
    };

    stylePath = mkOption {
      type = types.path;
      default = ./config/style.css;
      description = "Path to the wlogout CSS style file.";
    };
  };

  config = mkIf cfg.enable {
    programs.wlogout = {
      enable = true;
      package = pkgs.wlogout;

      # We read the local files into the HM module options
      layout = builtins.fromJSON (builtins.readFile cfg.layoutPath);
      style = builtins.readFile cfg.stylePath;
    };

    # We also ensure the icons (if you have them in the config folder) are linked
    xdg.configFile."wlogout/icons" = {
      source = ./config/icons;
      recursive = true;
    };
  };
}
