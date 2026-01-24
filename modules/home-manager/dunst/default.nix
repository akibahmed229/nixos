{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.dunst;
in {
  options.hm.dunst = {
    enable = mkEnableOption "Dunst notification daemon configuration";

    configFile = mkOption {
      type = types.path;
      default = ./config/dunstrc;
      description = "Path to the dunstrc configuration file.";
    };
  };

  config = mkIf cfg.enable {
    # services.dunst.enable handles both the package and the systemd service
    services.dunst = {
      enable = true;
      package = pkgs.dunst;

      # We tell Home Manager to use your existing dunstrc file
      configFile = cfg.configFile;
    };

    # Optional: ensure libnotify is available for testing with 'notify-send'
    home.packages = [pkgs.libnotify];
  };
}
