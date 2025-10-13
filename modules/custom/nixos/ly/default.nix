{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nm.ly;
in {
  options.nm.ly = {
    enable = mkEnableOption "Enable Ly, A lightweight TUI (ncurses-like) display manager for Linux and BSD.";
    session = mkOption {
      type = types.str;
      default = "Niri";
      description = "Set Your Default Environment.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.displayManager = {
      ly.enable = true;
      defaultSession = "Niri";
    };
  };
}
