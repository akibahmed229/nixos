{
  pkgs,
  lib,
  config,
  self,
  ...
}:
with lib; let
  cfg = config.hm.espanso;
in {
  options.hm.espanso = {
    enable = mkEnableOption "Espanso text expander configuration";

    isWayland = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to use the Wayland version of Espanso.";
    };

    extraMatches = mkOption {
      type = types.listOf types.attrs;
      default = [];
      description = "Additional matches to add to the base config.";
    };
  };

  config = mkIf cfg.enable {
    services.espanso = {
      enable = true;
      package =
        if cfg.isWayland
        then pkgs.espanso-wayland
        else pkgs.espanso;
      waylandSupport = cfg.isWayland;
      x11Support = !cfg.isWayland;

      matches = {
        base = {
          # Import the prompt snippets from the separate file
          matches =
            lib.flatten (self.lib.mkScanImportPath {inherit lib;} ./.)
            ++ cfg.extraMatches;
        };
      };
    };
  };
}
