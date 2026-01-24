{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.swaylock;
in {
  options.hm.swaylock = {
    enable = mkEnableOption "Swaylock (Effects) screen locker configuration";

    configDir = mkOption {
      type = types.path;
      default = ./config;
      description = "Path to the swaylock configuration directory.";
    };
  };

  config = mkIf cfg.enable {
    # We use the programs.swaylock module for better integration
    programs.swaylock = {
      enable = true;
      # Use the effects fork for blur, clock, and screenshots
      package = pkgs.swaylock-effects;
    };

    # Link the configuration folder
    xdg.configFile."swaylock" = {
      source = cfg.configDir;
      recursive = true;
    };
  };
}
