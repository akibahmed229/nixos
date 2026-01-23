{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.hypridle;
in {
  options.hm.hypridle = {
    enable = mkEnableOption "Hyprland idle daemon configuration";

    lockTime = mkOption {
      type = types.int;
      default = 3600; # 1 hour default
      description = "Inactivity timeout in seconds before locking the screen.";
    };

    lockCmd = mkOption {
      type = types.str;
      default = "qs ipc call lockscreen lock";
      description = "The command used to lock the screen.";
    };

    extraListeners = mkOption {
      type = types.listOf types.attrs;
      default = [];
      description = "Additional listeners (e.g., for dimming the screen or suspend).";
    };
  };

  config = mkIf cfg.enable {
    services.hypridle = {
      enable = true;
      package = pkgs.hypridle;

      settings = {
        general = {
          # Recommended defaults for a smooth experience
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };

        listener =
          [
            {
              timeout = cfg.lockTime;
              on-timeout = cfg.lockCmd;
            }
          ]
          ++ cfg.extraListeners;
      };
    };
  };
}
