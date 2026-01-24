{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.libinput;
in {
  options.hm.libinput = {
    enable = mkEnableOption "Libinput local overrides and quirks";

    quirkSource = mkOption {
      type = types.path;
      default = ./local-overrides.quirk;
      description = "Path to the local-overrides.quirk file.";
    };
  };

  config = mkIf cfg.enable {
    # Libinput looks for quirks in ~/.config/libinput/
    xdg.configFile."libinput/local-overrides.quirk" = {
      source = cfg.quirkSource;
    };
  };
}
